require 'socket'
require 'json'

class Flail
  class Exception
    def initialize(env, exception, local = false)
      @exception = exception
      @env = env
    end

    #
    # Helpers
    #
    def request
      @request ||= if @env['flail.request']
                     @env['flail.request']
                   else
                     ActionDispatch::Request.new(@env)
                   end
    end

    def request_data
      @request_data ||= if @env['flail.request.data']
                          @env['flail.request.data']
                        else
                          {
                            :parameters => {},
                            :user => {},
                          }
                        end
    end

    def clean_unserializable_data(data, stack = [])
      return "[possible infinite recursion halted]" if stack.any? {|item| item == data.object_id}

      if data.respond_to?(:to_hash)
        data.to_hash.inject({}) do |result, (key, value)|
          result.merge(key => clean_unserializable_data(value, stack + [data.object_id]))
        end
      elsif data.respond_to?(:to_ary)
        data.to_ary.collect do |value|
          clean_unserializable_data(value, stack + [data.object_id])
        end
      else
        input = if ''.respond_to?(:encode)
                  data.to_s.encode(Encoding::UTF_8, :undef => :replace)
                else
                  require 'iconv'
                  ic = Iconv.new("UTF-8//IGNORE", "UTF-8")
                  ic.iconv(data.to_s + ' ')[0..-2]
                end
        begin
          input.to_json
        rescue Exception => e
          input = "redundant utf-8 sequence"
        end

        input
      end
    end

    def clean_rack_env(data)
      data.delete("rack.request.form_vars")
      data.delete("rack.input")
      data
    end


    #
    # Handling the exception
    #
    def handle!
      Flail.swing(self.extract.to_json) unless self.ignore?
    end

    def extract
      @extract ||= begin
                     info = {}

                     # rack env
                     info[:rack]        = clean_unserializable_data(clean_rack_env(@env))

                     info[:class_name]  = @exception.class.name             # @exception class
                     info[:message]     = @exception.to_s                   # error message
                     info[:target_url]  = request_data[:target_url]         # url of request
                     info[:referer_url] = request_data[:referer_url]        # referer
                     info[:user_agent]  = request_data[:user_agent]         # user agent
                     info[:user]        = request_data[:user]               # current user

                     # backtrace of error
                     info[:trace]       = Flail::Backtrace.parse(@exception.backtrace, :filters => Flail::Backtrace::DEFAULT_FILTERS).to_hash

                     # request parameters
                     info[:parameters]  = clean_unserializable_data(request_data[:parameters])

                     # session
                     info[:session_data]= clean_unserializable_data(request_data[:session_data])

                     # special variables
                     info[:environment] = Flail.configuration.env
                     info[:hostname]    = Flail.configuration.hostname
                     info[:tag]         = Flail.configuration.tag

                     info
                   end
    end

    def ignore?
      # Ignore requests with user agent string matching
      # this regxp as they are surely made by bots
      if request.user_agent =~ /\b(Baidu|Gigabot|Googlebot|libwww-perl|lwp-trivial|msnbot|SiteUptime|Slurp|WordPress|ZIBB|ZyBorg|Yandex|Jyxobot|Huaweisymantecspider|ApptusBot)\b/i
        return true
      end

      false
    end
  end
end

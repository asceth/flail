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
                     info[:rack]        = @env.except('flail.request', 'flail.request.data')
                     info[:class_name]  = @exception.class.to_s             # @exception class
                     info[:message]     = @exception.to_s                   # error message
                     info[:trace]       = @exception.backtrace              # backtrace of error
                     info[:target_url]  = request_data[:target_url]         # url of request
                     info[:referer_url] = request_data[:referer_url]        # referer
                     info[:parameters]  = request_data[:parameters]         # request parameters
                     info[:user_agent]  = request_data[:user_agent]         # user agent
                     info[:user]        = request_data[:user]               # current user
                     info[:session_data]= request_data[:session_data]       # session

                     # special variables
                     info[:environment] = Flail.configuration.env
                     info[:hostname]    = Flail.configuration.hostname
                     info[:tag]    = Flail.configuration.tag

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

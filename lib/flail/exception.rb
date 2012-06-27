require 'socket'

class Flail
  class Exception
    def initialize(env, exception)
      @exception = exception
      @env = env
    end

    #
    # Helpers
    #
    def request
      @request ||= ActionDispatch::Request.new(@env)
    end

    def controller
      @controller ||= @env['action_controller.instance']
    end

    def user
      if controller.respond_to?(:current_user)
        current_user = controller.current_user

        {:id => current_user.id, :name => current_user.to_s}
      else
        {}
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

                     info[:class_name]  = @exception.class.to_s        # @exception class
                     info[:message]     = @exception.to_s              # error message
                     info[:trace]       = @exception.backtrace.to_json # backtrace of error
                     info[:target_url]  = request.url                  # url of request
                     info[:referer_url] = request.referer              # referer
                     info[:params]      = request.params.to_json       # request parameters
                     info[:user_agent]  = request.user_agent           # user agent
                     info[:user]        = self.user.to_json            # current user

                     # special variables
                     info[:environment] = Flail.configuration.env
                     info[:hostname]    = Flail.configuration.hostname
                     info[:api_key]    = Flail.configuration.api_key

                     info
                   end
    end

    def ignore?
      # Ignore requests with user agent string matching
      # this regxp as they are surely made by bots
      if @request.user_agent =~ /\b(Baidu|Gigabot|Googlebot|libwww-perl|lwp-trivial|msnbot|SiteUptime|Slurp|WordPress|ZIBB|ZyBorg|Yandex|Jyxobot|Huaweisymantecspider|ApptusBot)\b/i
        return true
      end

      false
    end
  end
end

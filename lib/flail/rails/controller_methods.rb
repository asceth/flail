class Flail
  module Rails
    module ControllerMethods
    
      def self.included(base)
        base.send(:before_filter, :inject_flail_data_into_environment)
      end

      # This method is inserted into the host application's controllers as a before_filter
      # and is used to pass the parameters, session data, user data, and URL data from the app's 
      # controller to the flail gem via the env variable (data is always passed, even if no 
      # exception is thrown). This hook only works when a host app's controller is called. 
      # Routing error exceptions are thrown before the controller is called so those errors are 
      # handled elsewhere and contain less information (mainly the user data is missing).
      def inject_flail_data_into_environment
        request.env['flail.request'] ||= request
        request.env['flail.request.data'] ||= flail_request_data
      end

      def flail_request_data
        {
          :parameters => params.to_hash,
          :session_data => flail_session_data,
          :target_url => request.url,
          :referer_url => request.referer,
          :user_agent => request.user_agent,
          :user => flail_user_data
        }
      end

      def flail_session_data
        if session.respond_to?(:to_hash)
          session.to_hash
        else
          session.data
        end
      end

      def flail_user_data
        user = current_user

        user.attributes.select do |k, v|
          /^(id|name|username|email|login)$/ === k unless v.blank?
        end
      rescue NoMethodError, NameError
        {}
      end
    end # ControllerMethods
  end
end

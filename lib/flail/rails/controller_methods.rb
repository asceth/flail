class Flail
  module Rails
    module ControllerMethods
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

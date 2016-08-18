class Flail
  module Rails
    module ActionDispatch
      def self.included(base)
        base.class_eval do
          prepend InstanceMethods
        end
      end

      module InstanceMethods
        def render_exception(request_or_env, exception)
          _env = if request_or_env.is_a?(::ActionDispatch::Request)
                   request_or_env.env
                 else
                   request_or_env
                 end

          Flail::Exception.new(_env, exception).handle!

          super
        end
      end
    end
  end
end

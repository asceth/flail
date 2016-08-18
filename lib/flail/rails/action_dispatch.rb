class Flail
  module Rails
    module ActionDispatch
      def self.included(base)
        base.class_eval do
          prepend InstanceMethods
        end
      end

      module InstanceMethods
        def render_exception(env, exception)
          Flail::Exception.new(env, exception).handle!
          super
        end
      end
    end
  end
end

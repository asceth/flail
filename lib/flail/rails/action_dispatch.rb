class Flail
  module Rails
    module ActionDispatch
      def self.included(base)
        base.send(:alias_method_chain, :render_exception, :flail)
      end

      def render_exception_with_flail(env, exception)
        Flail::Exception.new(env, exception).handle!

        render_exception_without_flail(env, exception)
      end
    end
  end
end

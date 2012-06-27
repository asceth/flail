class Flail
  module Rails
    module RescueAction
      # Sets up an alias chain to catch exceptions when Rails does
      def self.included(base)
        base.send(:alias_method, :rescue_action_in_public_without_flail, :rescue_action_in_public)
        base.send(:alias_method, :rescue_action_in_public, :rescue_action_in_public_with_flail)
      end

      private

      # Overrides the rescue_action method in ActionController::Base
      # but uses any custom processing that is defined with
      # Rails 2's exception helpers.
      def rescue_action_in_public_with_flail(exception)
        Flail::Exception.new(request.env, exception).handle!
        rescue_action_in_public_without_flail(exception)
      end
    end
  end
end

class Flail
  class Railtie < ::Rails::Railtie

    # Setup Flail::RackMiddlewareExceptionHook as the first rack middleware 
    # to catch exceptions that happen in the middleware chain.
    initializer "flail.use_rack_middleware" do |app|
      app.config.middleware.insert 0, Flail::RackMiddlewareExceptionHook
    end

    # Set the environment and host.
    config.after_initialize do
      Flail.configure do
        environment ::Rails.env
        host Socket.gethostname
      end

      # Add methods to the Aciont Controller so they may be run from within the
      # controller scope. Useful for getting user data and similar.
      ActiveSupport.on_load(:action_controller) do
        require 'flail/rails/controller_methods'
        include Flail::Rails::ControllerMethods
      end

      # Setup the hooks to catch typical exceptions when they happen.
      if defined?(::ActionDispatch::DebugExceptions)
        # Rails 3.2.x
        require 'flail/rails/action_dispatch'
        ::ActionDispatch::DebugExceptions.send(:include, Flail::Rails::ActionDispatch)

      elsif defined?(::ActionDispatch::ShowExceptions)
        # Rails 3.0.x || 3.1.x
        require 'flail/rails/action_dispatch'
        ::ActionDispatch::ShowExceptions.send(:include, Flail::Rails::ActionDispatch)
      end
    end
  end
end

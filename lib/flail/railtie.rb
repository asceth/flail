class Flail
  class Railtie < ::Rails::Railtie
    initializer "flail.use_rack_middleware" do |app|
      app.config.middleware.insert 0, "Flail::Rack"
    end

    config.after_initialize do
      Flail.configure do
        environment ::Rails.env
        host Socket.gethostname
      end

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

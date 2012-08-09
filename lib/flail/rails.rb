require 'flail'
require 'flail/rails/rescue_action'

if defined?(::ActionController::Base)
  ::ActionController::Base.send(:include, Flail::Rails::RescueAction)
  ::ActionController::Base.send(:include, Flail::Rails::ControllerMethods)
end

if defined?(::Rails.configuration) && ::Rails.configuration.respond_to?(:middleware)
  ::Rails.configuration.middleware.insert_after 'ActionController::Failsafe', Flail::Rack
end

Flail.configure do
  environment(defined?(::Rails.env) && ::Rails.env || defined?(RAILS_ENV) && RAILS_ENV)
  host Socket.gethostname
end

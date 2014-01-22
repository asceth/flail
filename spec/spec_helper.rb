require 'rubygems'
require 'bundler'
Bundler.setup

require 'rspec'
require 'rr'

RSpec.configure do |config|
  config.mock_with :rr
end

require 'active_record'
require 'rack'
require 'sham_rack'

require 'flail'
require 'flail/rails/controller_methods'


Dir["#{File.expand_path(File.dirname(__FILE__))}/support/*.rb"].map {|file| require(file)}

class FlailArmory

  module ClassMethods
    def define_constant(name, value)
      @defined_constants ||= []
      Object.const_set(name, value)
      @defined_constants << name
    end

    def build_controller_class(&definition)
      Class.new(ActionController::Base).tap do |klass|
        klass.__send__(:include, Flail::Rails::ControllerMethods)
        klass.class_eval(&definition) if definition

        klass.class_eval do
          def rescue_action_in_public_without_flail(*args)
          end
        end
        define_constant('FlailTestController', klass)
      end
    end

    def process_action(options = {}, &action)
      options[:request] ||= ActionController::TestRequest.new
      options[:response] ||= ActionController::TestResponse.new

      klass = build_controller_class do
        cattr_accessor :local
        define_method(:index, &action)

        def current_user
          @current_user
        end

        def local_request?
          local
        end
      end

      if options[:user_agent]
        if options[:request].respond_to?(:user_agent=)
          options[:request].user_agent = options[:user_agent]
        else
          options[:request].env["HTTP_USER_AGENT"] = options[:user_agent]
        end
      end

      klass.consider_all_requests_local = options[:all_local]
      klass.local = options[:local]

      controller = klass.new

      if options[:user]
        controller.instance_variable_set(:@current_user, options[:user])
      end

      options[:request].query_parameters = options[:request].query_parameters.merge(options[:params] || {})
      options[:request].session = ActionController::TestSession.new(options[:session] || {})
      options[:request].env['REQUEST_URI'] = options[:request].request_uri

      controller.process(options[:request], options[:response])
      controller
    end

    def process_action_with_error(options = {})
      process_action(options) do
        raise "Hello"
      end
    end

    def setup
      Flail.configure do
        handle do |payload|
          FlailArmory.payload = ActiveSupport::JSON.decode(payload)
        end
      end
      define_constant('RAILS_ROOT', '/path/to/rails/root')
    end

    def payload=(value)
      @payload = value
    end

    def payload
      @payload
    end

    def raid
      @defined_constants.each do |constant|
        Object.__send__(:remove_const, constant)
      end

      @payload = nil
      @defined_constants = []
    end
  end
  extend ClassMethods
end

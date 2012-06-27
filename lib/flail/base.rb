class Flail
  module ClassMethods
    def configure(&block)
      configuration.instance_eval(&block)
    end

    def configuration
      @configuration ||= Flail::Configuration.new.defaults!
    end

    def swing(payload)
      Flail.configuration.handler.call(payload)
    end
  end
  extend ClassMethods
end

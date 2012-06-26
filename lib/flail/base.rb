class Flail
  module ClassMethods
    def configure(&block)
      configuration.instance_eval(&block)
    end

    def configuration
      @configuration ||= Flail::Configuration.new
    end

    def swing(options = {})
      rack = options.delete(:rack)

      payload = {
        :error => options[:error].to_s,
        :message => options[:message].to_s,
        :backtrace => [options[:backtrace]].flatten.map(&:to_s),
        :session => options[:session],
        :url => options[:url] || rack(:url)
        :environment => options[:environment].to_s
        :server => options[:server].to_s
      }.to_json

      Flail.configuration.handler.call(payload)
    end
  end
  extend ClassMethods
end


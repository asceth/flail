class Flail
  class Configuration
    attr_accessor :handler, :endpoint

    def handle(&block)
      @handler = block
    end

    def url(endpoint)
      @endpoint = endpoint
    end
  end
end


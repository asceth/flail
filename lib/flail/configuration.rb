class Flail
  class Configuration
    # for the default handler
    HTTP_ERRORS = [Timeout::Error,
                   Errno::EINVAL,
                   Errno::ECONNRESET,
                   EOFError,
                   Net::HTTPBadResponse,
                   Net::HTTPHeaderSyntaxError,
                   Net::ProtocolError,
                   Errno::ECONNREFUSED].freeze

    # custom handler for payloads
    attr_reader :handler

    # endpoint for default handler (used with flail-web)
    attr_reader :endpoint

    # environment of application
    attr_reader :env

    # hostname sending the error
    attr_reader :hostname

    # is the endpoint ssl?
    attr_reader :secure_endpoint

    # api key to use with payloads
    attr_reader :tag


    def handle(&block)
      @handler = block
    end

    def url(endpoint)
      @endpoint = endpoint
    end

    def secure
      @secure_endpoint = true
    end

    def environment(value)
      @env = value
    end

    def host(value)
      @hostname = value
    end

    def tagged(value)
      @tag = value
    end

    def defaults!
      # configure some defaults
      @secure_endpoint = false

      handle do |payload|

        url = URI.parse(Flail.configuration.endpoint)

        http = Net::HTTP.new(url.host, url.port)

        http.read_timeout = 5
        http.open_timeout = 2

        if Flail.configuration.secure_endpoint
          http.use_ssl      = true
          http.verify_mode  = OpenSSL::SSL::VERIFY_PEER
        else
          http.use_ssl      = false
        end

        begin
          http.post(url.path, payload, {'Content-type' => 'application/json', 'Accept' => 'application/json'})
        rescue *HTTP_ERRORS => e
          nil
        end
      end

      self
    end # end defaults!
  end
end

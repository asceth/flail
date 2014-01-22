require 'net/http'
require 'net/https'
require 'socket'

require 'flail/base'
require 'flail/configuration'
require 'flail/backtrace'
require 'flail/exception'
require 'flail/rack_middleware_exception_hook'

# Railtie is not defined in spec tests so don't require during them.
require 'flail/railtie' if defined?(::Rails::Railtie)

class Flail
  class RackMiddlewareExceptionHook
    def initialize(app)
      @app = app
    end

    def call(env)
      begin
        response = @app.call(env)
      rescue ::Exception => exception
        STDERR.puts exception.inspect
        exception.backtrace.each do |line|
          STDERR.puts line.inspect
        end
        Flail::Exception.new(env, exception).handle!
        raise
      end

      if env['rack.exception']
        Flail::Exception.new(env, env['rack.exception']).handle!
      end

      response
    end
  end
end

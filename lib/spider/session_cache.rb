require 'spider/settings/proxy'
require 'spider/settings/timeouts'
require 'spider/spider'

require 'net/http'
require 'openssl'

module Spider

  class SessionCache

    include Settings::Proxy
    include Settings::Timeouts

    def initialize(options={})
      @proxy = options.fetch(:proxy,Spider.proxy)

      @open_timeout       = options.fetch(:open_timeout,Spider.open_timeout)
      @ssl_timeout        = options.fetch(:ssl_timeout,Spider.ssl_timeout)
      @read_timeout       = options.fetch(:read_timeout,Spider.read_timeout)
      @continue_timeout   = options.fetch(:continue_timeout,Spider.continue_timeout)
      @keep_alive_timeout = options.fetch(:keep_alive_timeout,Spider.keep_alive_timeout)

      @sessions = {}
    end


    def active?(url)      
      url = URI(url)

      key = key_for(url)

      return @sessions.has_key?(key)
    end

    def [](url)
      url = URI(url)

      key = key_for(url)

      unless @sessions[key]
        session = Net::HTTP::Proxy(
          @proxy.host,
          @proxy.port,
          @proxy.user,
          @proxy.password
        ).new(url.host,url.port)

        session.open_timeout       = @open_timeout       if @open_timeout
        session.read_timeout       = @read_timeout       if @read_timeout
        session.continue_timeout   = @continue_timeout   if @continue_timeout
        session.keep_alive_timeout = @keep_alive_timeout if @keep_alive_timeout

        if url.scheme == 'https'
          session.use_ssl     = true
          session.verify_mode = OpenSSL::SSL::VERIFY_NONE
          session.ssl_timeout = @ssl_timeout
          session.start
        end

        @sessions[key] = session
      end

      return @sessions[key]
    end

    def kill!(url)

      url = URI(url)

      key = key_for(url)

      if (sess = @sessions[key])
        begin 
          sess.finish
        rescue IOError
        end

        @sessions.delete(key)
      end
    end


    def clear
      @sessions.each_value do |session|
        begin
          session.finish
        rescue IOError
        end
      end

      @sessions.clear
      return self
    end

    private

    def key_for(url)
      [url.scheme, url.host, url.port]
    end

  end
end
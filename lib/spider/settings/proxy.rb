require 'spider/proxy'

module Spider
  module Settings
    module Proxy

      def proxy
        @proxy ||= Spidr::Proxy.new
      end

      def proxy=(new_proxy)
        @proxy = case new_proxy
                 when Spidr::Proxy then new_proxy
                 when Hash         then Spidr::Proxy.new(new_proxy)
                 when nil          then Spidr::Proxy.new
                 else
                   raise(TypeError,"#{self.class}#{__method__} only accepts Proxy, Hash or nil")
                 end
      end

      def disable_proxy!
        @proxy = Spidr::Proxy.new
        return true
      end
    end
  end
end
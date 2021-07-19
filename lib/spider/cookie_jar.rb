require 'spider/page'
require 'set'

module Spider

  class CookieJar

    include Enumerable

    def initialize
      @params = {}

      @dirty   = Set[]
      @cookies = {}
    end

    def each(&block)
      @params.each(&block)
    end

    def [](host)
      @params[host] ||= {}
    end


    def []=(host,cookies)
      collected = self[host]

      cookies.each do |key,value|
        if collected[key] != value
          collected.merge!(cookies)
          @dirty << host

          break
        end
      end

      return cookies
    end

    def from_page(page)
      cookies = page.cookie_params

      unless cookies.empty?
        self[page.url.host] = cookies
        return true
      end

      return false
    end

    def for_host(host)
      if @dirty.include?(host)
        values = []

        cookies_for_host(host).each do |name,value|
          values << "#{name}=#{value}"
        end

        @cookies[host] = values.join('; ')
        @dirty.delete(host)
      end

      return @cookies[host]
    end

    def cookies_for_host(host)
      host_cookies = (@params[host] || {})
      sub_domains  = host.split('.')

      while sub_domains.length > 2
        sub_domains.shift

        if (parent_cookies = @params[sub_domains.join('.')])
          parent_cookies.each do |name,value|

            unless host_cookies.has_key?(name)
              host_cookies[name] = value
            end
          end
        end
      end

      return host_cookies
    end


    def clear!
      @params.clear

      @dirty.clear
      @cookies.clear
      return self
    end

    def size
      @params.size
    end

    def inspect
      "#<#{self.class}: #{@params.inspect}>"
    end

  end
end
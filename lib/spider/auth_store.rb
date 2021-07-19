require 'spider/extensions/uri'
require 'spider/auth_credential'
require 'spider/page'

require 'base64'

module Spider

  class AuthStore

    def initialize
      @credentials = {}
    end

    def [](url)
      url = URI(url)

      key = [url.scheme, url.host, url.port]
      paths = @credentials[key]

      return nil unless paths

      ordered_paths = paths.keys.sort_by { |path_key| -path_key.length }

      path_dirs = URI.expand_path(url.path).split('/')

      ordered_paths.each do |path|
        return paths[path] if path_dirs[0,path.length] == path
      end

      return nil
    end

    def []=(url,auth)
      url = URI(url)

      path = URI.expand_path(url.path)

      key = [url.scheme, url.host, url.port]

      @credentials[key] ||= {}
      @credentials[key][path.split('/')] = auth
      return auth
    end

    def add(url,username,password)
      self[url] = AuthCredential.new(username,password)
    end

    def for_url(url)
      if (auth = self[url])
        Base64.encode64("#{auth.username}:#{auth.password}")
      end
    end

    def clear!
      @credentials.clear
      return self
    end


    def size
      total = 0

      @credentials.each_value { |paths| total += paths.length }

      return total
    end

    def inspect
      "#<#{self.class}: #{@credentials.inspect}>"
    end

  end
end
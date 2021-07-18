require 'set'

module Spider
  class Page
    RESERVED_COOKIE_NAMES = /^(?:Path|Expires|Domain|Secure|HTTPOnly)$/i


    def cookie
      @response['Set-Cookie'] || ''
    end

    alias raw_cookie cookie

    def cookies
      (@response.get_fields('Set-Cookie') || [])
    end


    def cookie_params
      params = {}

      cookies.each do |value|
        value.split(';').each do |param|
          param.strip!

          name, value = param.split('=',2)

          unless name =~ RESERVED_COOKIE_NAMES
            params[name] = (value || '')
          end
        end
      end

      return params
    end
  end
end
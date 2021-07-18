require 'set'

module Spider
    class Page

        RESERVED_COOKIES_NAMES = /^(?:Path|Expires|Domain|Secure|HTTPOnly)$/i

        def cookie
            @response['Set-Cokkie'] || ''
        end

        alias raw_cookie cookie

        def cookies
            (@response.get_fields('Set-Cookie') || [])
        end
    end
end

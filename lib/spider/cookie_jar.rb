require 'spider/page'
require 'set'

module Spider
    class CookieJar
        include Enumerable

        def initialize
            @params = {}
            @dirty = Set[]
            @cookies = {}
        end

        def each(&block)
            @params.each(&block)
        end

        def [](host)
            @params[host] || = {}
        end
        
        
        def []=(host, cookies)
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
        
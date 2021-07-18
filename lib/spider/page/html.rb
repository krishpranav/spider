require 'nokogiri'
require 'spider/extensions/uri'

module Spider
  class Page
    include Enumerable

    def title
      if (node = at('//title'))
        node.inner_text
      end
    end


    def each_meta_redirect
      return enum_for(__method__) unless block_given?

      if (html? && doc)
        search('//meta[@http-equiv and @content]').each do |node|
          if node.get_attribute('http-equiv') =~ /refresh/i
            content = node.get_attribute('content')

            if (redirect = content.match(/url=(\S+)$/))
              yield redirect[1]
            end
          end
        end
      end
    end

    def meta_redirect?
      !each_meta_redirect.first.nil?
    end

    def meta_redirects
      each_meta_redirect.to_a
    end

    def meta_redirect
      warn 'DEPRECATION: Spidr::Page#meta_redirect will be removed in 0.3.0'
      warn 'DEPRECATION: Use Spidr::Page#meta_redirects instead'

      meta_redirects
    end


    def each_redirect(&block)
      return enum_for(__method__) unless block

      if (locations = @response.get_fields('Location'))
        locations.each(&block)
      else
        each_meta_redirect(&block)
      end
    end

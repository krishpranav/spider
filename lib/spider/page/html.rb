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


    def redirects_to
      each_redirect.to_a
    end

    def each_mailto
      return enum_for(__method__) unless block_given?

      if (html? && doc)
        doc.search('//a[starts-with(@href,"mailto:")]').each do |a|
          yield a.get_attribute('href')[7..-1]
        end
      end
    end

    def mailtos
      each_mailto.to_a
    end

    def each_link
      return enum_for(__method__) unless block_given?

      filter = lambda { |url|
        yield url unless (url.nil? || url.empty?)
      }

      each_redirect(&filter) if is_redirect?

      if (html? && doc)
        doc.search('//a[@href]').each do |a|
          filter.call(a.get_attribute('href'))
        end

        doc.search('//frame[@src]').each do |iframe|
          filter.call(iframe.get_attribute('src'))
        end

        doc.search('//iframe[@src]').each do |iframe|
          filter.call(iframe.get_attribute('src'))
        end

        doc.search('//link[@href]').each do |link|
          filter.call(link.get_attribute('href'))
        end

        doc.search('//script[@src]').each do |script|
          filter.call(script.get_attribute('src'))
        end
      end
    end

    def links
      each_link.to_a
    end

    def each_url
      return enum_for(__method__) unless block_given?

      each_link do |link|
        if (url = to_absolute(link))
          yield url
        end
      end
    end

    alias each each_url


    def urls
      each_url.to_a
    end

    def to_absolute(link)
      link    = link.to_s
      new_url = begin
                  url.merge(link)
                rescue Exception
                  return
                end

      if (!new_url.opaque) && (path = new_url.path)
        if (new_url.scheme == 'ftp' && !path.start_with?('/'))
          path.insert(0,'/')
        end

        new_url.path = URI.expand_path(path)
      end

      return new_url
    end
  end
end
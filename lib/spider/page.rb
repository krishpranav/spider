module Spider

    class Page
  
      attr_reader :url
  
      attr_reader :response
  
      attr_reader :headers
  
      def initialize(url,response)
        @url      = url
        @response = response
        @headers  = response.to_hash
        @doc      = nil
      end
  
      def body
        (response.body || '')
      end
  
      alias to_s body
  
      def doc
        unless body.empty?
          doc_class = if html?
                        Nokogiri::HTML::Document
                      elsif rss? || atom? || xml? || xsl?
                        Nokogiri::XML::Document
                      end
  
          if doc_class
            begin
              @doc ||= doc_class.parse(body, @url.to_s, content_charset)
            rescue
            end
          end
        end
      end
  

      def search(*paths)
        if doc
          doc.search(*paths)
        else
          []
        end
      end
  
      def at(*arguments)
        if doc
          doc.at(*arguments)
        end
      end
  
      alias / search
      alias % at
  
      protected
  
      def method_missing(name,*arguments,&block)
        if (arguments.empty? && block.nil?)
          header_name = name.to_s.tr('_','-')
  
          if @response.key?(header_name)
            return @response[header_name]
          end
        end
  
        return super(name,*arguments,&block)
      end
    
    end
  end
  
  require 'spider/page/status_codes'
  require 'spider/page/content_types'
  require 'spider/page/cookies'
  require 'spider/page/html'
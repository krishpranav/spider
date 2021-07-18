module Spider
    class Agent

      def every_url(&block)
        @every_url_blocks << block
        return self
      end
  

      def every_failed_url(&block)
        @every_failed_url_blocks << block
        return self
      end
  

      def every_url_like(pattern,&block)
        @every_url_like_blocks[pattern] << block
        return self
      end
  

      def urls_like(pattern,&block)
        every_url_like(pattern,&block)
      end
  

      def all_headers
        every_page { |page| yield page.headers }
      end
  

      def every_page(&block)
        @every_page_blocks << block
        return self
      end
  

      def every_ok_page
        every_page do |page|
          yield page if (block_given? && page.ok?)
        end
      end
  
      def every_redirect_page
        every_page do |page|
          yield page if (block_given? && page.redirect?)
        end
      end
  
      def every_timedout_page
        every_page do |page|
          yield page if (block_given? && page.timedout?)
        end
      end
  

      def every_bad_request_page
        every_page do |page|
          yield page if (block_given? && page.bad_request?)
        end
      end
  
      def every_unauthorized_page
        every_page do |page|
          yield page if (block_given? && page.unauthorized?)
        end
      end
  
      
      def every_forbidden_page
        every_page do |page|
          yield page if (block_given? && page.forbidden?)
        end
      end
  
 
      def every_missing_page
        every_page do |page|
          yield page if (block_given? && page.missing?)
        end
      end
  

      def every_internal_server_error_page
        every_page do |page|
          yield page if (block_given? && page.had_internal_server_error?)
        end
      end
  

      def every_txt_page
        every_page do |page|
          yield page if (block_given? && page.txt?)
        end
      end
  

      def every_html_page
        every_page do |page|
          yield page if (block_given? && page.html?)
        end
      end
  

      def every_xml_page
        every_page do |page|
          yield page if (block_given? && page.xml?)
        end
      end
  

      def every_xsl_page
        every_page do |page|
          yield page if (block_given? && page.xsl?)
        end
      end
  

      def every_doc
        every_page do |page|
          if block_given?
            if (doc = page.doc)
              yield doc
            end
          end
        end
      end
  

      def every_html_doc
        every_page do |page|
          if (block_given? && page.html?)
            if (doc = page.doc)
              yield doc
            end
          end
        end
      end
  
   
      def every_xml_doc
        every_page do |page|
          if (block_given? && page.xml?)
            if (doc = page.doc)
              yield doc
            end
          end
        end
      end
  

      def every_xsl_doc
        every_page do |page|
          if (block_given? && page.xsl?)
            if (doc = page.doc)
              yield doc
            end
          end
        end
      end

      def every_rss_doc
        every_page do |page|
          if (block_given? && page.rss?)
            if (doc = page.doc)
              yield doc
            end
          end
        end
      end
  

      def every_atom_doc
        every_page do |page|
          if (block_given? && page.atom?)
            if (doc = page.doc)
              yield doc
            end
          end
        end
      end
  

      def every_javascript_page
        every_page do |page|
          yield page if (block_given? && page.javascript?)
        end
      end
  

      def every_css_page
        every_page do |page|
          yield page if (block_given? && page.css?)
        end
      end
  

      def every_rss_page
        every_page do |page|
          yield page if (block_given? && page.rss?)
        end
      end
  

      def every_atom_page
        every_page do |page|
          yield page if (block_given? && page.atom?)
        end
      end
  

      def every_ms_word_page
        every_page do |page|
          yield page if (block_given? && page.ms_word?)
        end
      end
  

      def every_pdf_page
        every_page do |page|
          yield page if (block_given? && page.pdf?)
        end
      end
  
      def every_zip_page
        every_page do |page|
          yield page if (block_given? && page.zip?)
        end
      end
  
      def every_link(&block)
        @every_link_blocks << block
        return self
      end
  
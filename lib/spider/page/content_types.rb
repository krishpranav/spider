module Spidr
    class Page

      def content_type
        @response['Content-Type'] || ''
      end
  
      def content_types
        @response.get_fields('content-type') || []
      end
  
      def content_charset
        content_types.each do |value|
          if value.include?(';')
            value.split(';').each do |param|
              param.strip!
  
              if param.start_with?('charset=')
                return param.split('=',2).last
              end
            end
          end
        end
  
        return nil
      end
  
      def is_content_type?(type)
        if type.include?('/')
          content_types.any? do |value|
            value = value.split(';',2).first
  
            value == type
          end
        else
          # otherwise only match the sub-type
          content_types.any? do |value|
            value = value.split(';',2).first
            value = value.split('/',2).last
  
            value == type
          end
        end
      end
  
      def plain_text?
        is_content_type?('text/plain')
      end
  
      alias txt? plain_text?
  
      def directory?
        is_content_type?('text/directory')
      end
  

      def html?
        is_content_type?('text/html')
      end
  
      def xml?
        is_content_type?('text/xml') || \
          is_content_type?('application/xml')
      end
  

      def xsl?
        is_content_type?('text/xsl')
      end
  
      def javascript?
        is_content_type?('text/javascript') || \
          is_content_type?('application/javascript')
      end
  
      
      def json?
        is_content_type?('application/json')
      end
  
      def css?
        is_content_type?('text/css')
      end
  
      def rss?
        is_content_type?('application/rss+xml') || \
          is_content_type?('application/rdf+xml')
      end
  
      def atom?
        is_content_type?('application/atom+xml')
      end
  
      def ms_word?
        is_content_type?('application/msword')
      end
  
      def pdf?
        is_content_type?('application/pdf')
      end
  
      def zip?
        is_content_type?('application/zip')
      end
    end
  end
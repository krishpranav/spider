module Spider
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
        
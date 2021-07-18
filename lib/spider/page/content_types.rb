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

        def is_content_type?(type)
            if type.include?('/')

                content_types.any? do |value|
                    value = value.split(';',2).first

                    value == type
                end

            else
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
        
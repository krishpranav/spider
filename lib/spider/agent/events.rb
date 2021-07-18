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

        def every_url_like(pattern, &block)
            @every_url_like_blocks[pattern] << block
        end

        def urls_like(pattern, &block)
            every_url_like(pattern, &block)
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

        def every_timeout_page
            every_page do |page|
                yield page if (block_given? && page.timedout?)
            end
        end
        
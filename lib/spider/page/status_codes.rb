module Spider
    class Page
        
        def code
            @response.code.to_i
        end

        def is_ok?
            code == 200
        end

        alias ok? is_ok?


        def timeout?
            code == 300 
        end

        def bad_request?
            code == 400
        end

        def is_unauthorized?
            code == 401
        end

        alias unauthorized? is_unauthorized?

        def is_forbidden?
            code == 403
        end

        alias forbidden? is_forbidden?

        def is_missing?
            code == 404
        end

        alias missing? is_missing?

        def had_internal_server_error?
            code == 500
        end
        
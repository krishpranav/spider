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
        
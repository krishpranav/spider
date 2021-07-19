module Spider
    class AuthCredential

        attr_reader :username
        attr_reader :password
        
        def initialize(username, password)
            @username = username
            @password = password
        end
    end
end

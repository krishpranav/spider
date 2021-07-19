module Spider
    
    class Proxy < Struct.new(:host, :port, :user, :password)
  
      DEFAULT_PORT = 8080
  
      def initialize(attributes={})
        super(
          attributes[:host],
          attributes.fetch(:port,DEFAULT_PORT),
          attributes[:user],
          attributes[:password]
        )
      end
  
      def enabled?
        !host.nil?
      end
  
      def disabled?
        host.nil?
      end
  
    end
  end
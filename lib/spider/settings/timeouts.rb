module Spider
    module Settings

      module Timeouts
        
        attr_accessor :read_timeout
        attr_accessor :open_timeout
        attr_accessor :ssl_timeout
        attr_accessor :continue_timeout
        attr_accessor :keep_alive_timeout
      end
    end
  end
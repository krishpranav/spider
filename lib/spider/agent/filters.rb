require 'spider/rules'

module Spider
    class Agent
        attr_reader :schemes

        def schemes=(new_schemes)
            @schemes = new_schemes.map(&:to_s)
        end
        
        def visit_hosts
            @host_rules.accept
        end

        def visit_hosts_like(pattern=nil, &block)
            if pattern
                visit_hosts << pattern
            elsif block
                visit_hosts << block
            end

            return self
        end

        def visit_ports
            @port_rules.accept
        end

        def visit_ports_like(pattern=nil, &block)
            if pattern
                visit_ports << pattern
            elsif block
                visit_ports << block
            end
            
            return self
        end
        
begin
    require 'robots'
rescue LoadError
end

module Spider
    class Agent
        
        def initialize_robots
            unless Object.const_defined?(:Robots)
                raise(ArgumentError,":robots option given but unable to require 'robots' gem")
            end

            @robots = Robots.new(@user_agent)
        end
        
module Spider
    class Agent
        module Actions

            class Actions RuntimeError
            end

            class Paused < Action
            end

            class SkipLink < Action
            end

            class SkipPage < Action
            end
        end
        
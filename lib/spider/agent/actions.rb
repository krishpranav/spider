module Spider
    class Agent
      module Actions

        class Action < RuntimeError
        end
  
        class Paused < Action
        end
  
        class SkipLink < Action
        end
  
        class SkipPage < Action
        end
      end
  
      def continue!(&block)
        @paused = false
        return run(&block)
      end
  
      def pause=(state)
        @paused = state
      end
  
      def pause!
        @paused = true
        raise(Actions::Paused)
      end
  
      def paused?
        @paused == true
      end
  
      def skip_link!
        raise(Actions::SkipLink)
      end
  
      def skip_page!
        raise(Actions::SkipPage)
      end
  
      protected
  
      def initialize_actions(options={})
        @paused = false
      end
    end
  end
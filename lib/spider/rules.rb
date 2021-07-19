module Spider

    class Rules
  
      attr_reader :accept
  
      attr_reader :reject
  
      def initialize(options={})
        @accept = []
        @reject = []
  
        @accept += options[:accept] if options[:accept]
        @reject += options[:reject] if options[:reject]
      end
  
      def accept?(data)
        unless @accept.empty?
          @accept.any? { |rule| test_data(data,rule) }
        else
          !@reject.any? { |rule| test_data(data,rule) }
        end
      end
  
      def reject?(data)
        !accept?(data)
      end
  
      protected
  
      def test_data(data,rule)
        if rule.kind_of?(Proc)
          rule.call(data) == true
        elsif rule.kind_of?(Regexp)
          !((data.to_s =~ rule).nil?)
        else
          data == rule
        end
      end
  
    end
  end
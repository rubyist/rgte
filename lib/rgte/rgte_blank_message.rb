module RGTE
  class BlankMessage
    class << self
      def matched?
        false
      end
      
      def method_missing(m, *args)
        self
      end
    end
  end
end

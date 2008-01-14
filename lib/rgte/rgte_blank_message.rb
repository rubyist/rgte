module RGTE
  class BlankMessage #:nodoc:
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

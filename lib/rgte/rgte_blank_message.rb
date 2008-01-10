module RGTE
  class BlankMessage
    class << self
      def method_missing(m, *args)
        self
      end
    end
  end
end

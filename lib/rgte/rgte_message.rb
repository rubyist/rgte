module RGTE
  class Message
    def initialize(filename)
      @filename = filename
    end
    
    def read
      unless flags.include?('S')
        flagged_name = add_flag('S')
        FileUtils.mv(@filename, flagged_name)
        @filename = flagged_name
      end
    end

    private
    def add_flag(flag)
      f = flags
      f << flag
      "#{base}:2,#{f.uniq.sort.join}"
    end

    def base
      @filename =~ /(.+):2,D?F?P?R?S?T?/
      $1
    end

    def flags
      @filename =~ /.+:2,(D?F?P?R?S?T?)/
      $1.split('')
    end
  end
end

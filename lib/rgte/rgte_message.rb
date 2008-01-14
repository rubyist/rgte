module RGTE
  class Message
    class << self
      def message_filename
        mid = "RGTE#{rand(100000)}#{Time.now.to_i.to_s}#{Process.pid}"
        filebase = "#{Time.now.to_i.to_s}.#{mid}.rgte"
        "#{filebase}:2,"
      end
    end
    
    def initialize(body)
      @body = body
      @saved = false
      @flags = []
      @mailbox = nil
    end

    def read
      @flags << 'S' unless @flags.include?('S')
      self
    end

    def read?
      @flags.include?('S')
    end

    def saved?
      @saved
    end

    def save(mailbox)
      @mailbox = mailbox
      @saved = true
      self
    end

    def write
      return unless saved?
      
      mbname = mailbox_name(@mailbox)
      msname = message_filename
      full_path = "#{mbname}/#{msname}"
      
      FileUtils.mkdir_p(mbname)
      File.open(full_path, 'w') do |f|
        f.write @body
      end
    end

    def halt
      raise RGTE::HaltFilter
    end

    def matched?
      true
    end

    private
    def mailbox_name(mailbox)
      if mailbox == 'inbox'
        File.join(RGTE::Config[:maildir_root], '/cur')
      else
        File.join(RGTE::Config[:maildir_root], ".#{mailbox.sub('/', '.')}", 'cur')
      end
    end

    def message_filename
      "#{self.class.message_filename}#{@flags.uniq.sort.join}"
    end
  end
end

require 'rubygems'
require 'tmail'
require 'fileutils'

module RGTE
  MAILDIR_ROOT = '/home/scott/Maildir'
  MAILDIR_BACKUP = '/home/scott/Mail-backup'

  class Filter
    def initialize(str)
      @message = TMail::Mail.parse str
      @rgte_message = RGTE::Message.new str
      @groups = {}
    end
    
    def process!
      instance_eval(open("/home/scott/.rgte-rules").read)
      @rgte_message.save('inbox') unless @rgte_message.saved?
      @rgte_message.write
    end

    def group(name, *args)
      @groups[name] = args
    end

    def from(addrs, mailbox=nil)
      return RGTE::BlankMessage if @rgte_message.saved? && !mailbox.nil?
      
      addresses = address_lookup(addrs)

      if addresses.any? {|addr| Array(@message.from).any? {|a| a =~ /#{addr}/i}}
        @rgte_message.save(mailbox) if mailbox
        @rgte_message
      else
        RGTE::BlankMessage
      end
    end

    # list is a special construct for mailing lists that matches To, Cc, From
    def list(addrs, mailbox=nil)
      return RGTE::BlankMessage if @rgte_message.saved? && !mailbox.nil?

      addresses = address_lookup(addrs)
      found = false

      [:to, :cc, :from].each do |header|
        found = true if addresses.any? {|addr| Array(@message.send(header)).any? {|a| a =~ /#{addr}/i} }
        break if found
      end

      if found
        @rgte_message.save(mailbox) if mailbox
        @rgte_message
      else
        RGTE::BlankMessage
      end
    end

    def pipe(process, match, mailbox=nil)
      return RGTE::BlankMessage if @rgte_message.saved? && !mailbox.nil?

      f = IO.popen(process, 'r+')
      f.print @message
      f.close_write
      output = f.read
      f.close_read
      if output =~ match
        @rgte_message.save(mailbox) if mailbox
        @rgte_message
      else
        RGTE::BlankMessage
      end
    end

    def backup
      backupdir = "#{RGTE::MAILDIR_BACKUP}/#{Time.now.strftime('%Y-%m')}/cur"
      FileUtils.mkdir_p backupdir
      open("#{backupdir}/#{RGTE::Message.message_filename}", 'w') do |f|
        f.write @message
      end
    end

    private
    def address_lookup(addrs)
      addrs.is_a?(Symbol) ? @groups[addrs] : Array(addrs)
    end
  end
end

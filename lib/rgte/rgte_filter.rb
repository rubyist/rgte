require 'rubygems'
require 'tmail'
require 'fileutils'

module RGTE
  class HaltFilter < Exception;end

  class Config       #:nodoc:
    class << self
      def [](key)
        @config ||= {}
        @config[key]
      end

      def []=(key, val)
        @config ||= {}
        @config[key] = val
      end
    end
  end

  class Filter
    def initialize(str, rules) #:nodoc:
      RGTE::Config[:inbox] = 'inbox'
      RGTE::Config[:maildir_root] = File.join(ENV['HOME'], 'Maildir')
      RGTE::Config[:maildir_backup] = File.join(ENV['HOME'], 'Mail-backup')
      RGTE::Config[:rules] = rules || File.join(ENV['HOME'], '.rgte-rules')
      
      @message = TMail::Mail.parse str
      @rgte_message = RGTE::Message.new str
      @groups = {}
    end
    
    def process! #:nodoc:
      begin
        instance_eval(open(RGTE::Config[:rules]).read)
      rescue RGTE::HaltFilter
      ensure
        # TODO if we halt but haven't saved, default to the inbox or don't save?
        @rgte_message.save(RGTE::Config[:inbox]) unless @rgte_message.saved?
        @rgte_message.write if @rgte_message.saved?
        exit(@rgte_message.saved? ? 0 : 1)
      end
    end

    def config(config_hash)
      config_hash.each { |k, v| RGTE::Config[k] = v }
    end

    def inbox(mailbox)
      RGTE::Config[:inbox] = mailbox
    end

    def group(name, *args)
      @groups[name] = args
    end

    def from(addrs, mailbox=nil)
      address_match('from', addrs, mailbox)
    end

    def to(addrs, mailbox=nil)
      address_match('to', addrs, mailbox)
    end

    def cc(addrs, mailbox=nil)
      address_match('cc', addrs, mailbox)
    end

    # A special construct for mailing lists that matches To, Cc, From
    def list(addrs, mailbox=nil)
      return @rgte_message if to(addrs, mailbox).matched?
      return @rgte_message if cc(addrs, mailbox).matched?
      return @rgte_message if from(addrs, mailbox).matched?
      RGTE::BlankMessage
    end

    def subject(subj, mailbox=nil)
      header('subject', subj, mailbox)
    end

    def header(header, match, mailbox=nil)
      save_or_blank(matches_header?(header, match), mailbox)
    end

    def pipe(process, match, mailbox=nil)
      return RGTE::BlankMessage if @rgte_message.saved? && !mailbox.nil?

      f = IO.popen(process, 'r+')
      f.print @message
      f.close_write
      output = f.read
      f.close_read

      save_or_blank(output =~ match, mailbox)
    end

    def backup
      backupdir = File.join(RGTE::Config[:maildir_backup], Time.now.strftime('%Y-%m'), '/cur')
      FileUtils.mkdir_p backupdir
      open("#{backupdir}/#{RGTE::Message.message_filename}", 'w') do |f|
        f.write @message
      end
    end

    private
    def has_inbox?
      !RGTE::Config[:inbox].nil?
    end
    
    def address_lookup(addrs)
      addrs.is_a?(Symbol) ? @groups[addrs] : Array(addrs)
    end

    def matches_header?(header, match)
      @message[header].to_s =~ /#{match}/i
    end

    def address_match(header, addrs, mailbox=nil)
      return RGTE::BlankMessage if @rgte_message.saved? && !mailbox.nil?

      addresses = address_lookup(addrs)

      save_or_blank(addresses.any? {|addr| matches_header?(header, addr)}, mailbox)
    end

    def save_or_blank(pred, mailbox)
      return RGTE::BlankMessage if @rgte_message.saved? && !mailbox.nil?

      if pred
        @rgte_message.save(mailbox) if mailbox
        @rgte_message
      else
        RGTE::BlankMessage
      end
    end
  end
end

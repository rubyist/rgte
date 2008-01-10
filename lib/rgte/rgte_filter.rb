require 'rubygems'
require 'tmail'
require 'fileutils'

module RGTE
  MAILDIR_ROOT = '/home/scott/Maildir'
  MAILDIR_BACKUP = '/home/scott/Mail-backup'

  class RuleFinished < Exception
  end

  class Filter
    def initialize(str)
      @message = TMail::Mail.parse str
    end
    
    def process!
      begin
        instance_eval(open("/home/scott/.rgte-rules").read)
      rescue RGTE::RuleFinished
      else
        save_to 'inbox'
      end
    end

    def list(address, mailbox, &block)
      [:to, :cc, :from].each do |header|
        if Array(@message.send(header)).any? {|addr| addr =~ /#{address}/i}
          msg = save_to mailbox
          yield(msg) if block_given?
          raise RGTE::RuleFinished
        end
      end
    end

    def pipe(process, match, mailbox, &block)
      f = IO.popen(process, 'r+')
      f.print @message
      f.close_write
      output = f.read
      f.close_read
      if output =~ match
        save_to mailbox
        raise RGTE::RuleFinished
      end
    end

    def backup
      backupdir = "#{RGTE::MAILDIR_BACKUP}/#{Time.now.strftime('%Y-%m')}/cur"
      FileUtils.mkdir_p backupdir
      open("#{backupdir}/#{message_filename}", 'w') do |f|
        f.write @message
      end
    end

    private
    def save_to(mailbox)
      mbname = mailbox_name(mailbox)
      msname = message_filename
      full_path = "#{mbname}/#{msname}"
      
      FileUtils.mkdir_p(mbname)
      open(full_path, 'w') do |f|
        f.write @message
      end
      RGTE::Message.new(full_path)
    end

    def mailbox_name(mailbox)
      if mailbox == 'inbox'
        "#{RGTE::MAILDIR_ROOT}/cur"
      else
        "#{RGTE::MAILDIR_ROOT}/.#{mailbox.sub('/', '.')}/cur"
      end
    end

    def message_filename
      mid = "RGTE#{rand(100000)}#{Time.now.to_i.to_s}#{Process.pid}"
      filebase = "#{Time.now.to_i.to_s}.#{mid}.rgte"
      "#{filebase}:2,"
    end
  end
end

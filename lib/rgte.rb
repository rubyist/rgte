require 'optparse'
require File.join(File.dirname(__FILE__), 'rgte', 'rgte_message')
require File.join(File.dirname(__FILE__), 'rgte', 'rgte_blank_message')
require File.join(File.dirname(__FILE__), 'rgte', 'rgte_filter')

module RGTE
  VERSION = '0.0.3'

  class << self
    def application #:nodoc:
      @application ||= RGTE::Application.new
    end
  end
end

module RGTE
  class Application #:nodoc:
    def initialize
      OptionParser.new do |opts|
        opts.banner = "Usage: rgte [options] < <file>"
        opts.on("-v", "--version", "Print the version") {version; exit}
        opts.on("-f", "--file FILE",    "Specify a rules file") {|f| self.rules = f }
      end.parse!
    end

    def run
      RGTE::Filter.new(STDIN.read, @rules).process!
    end
    
    def version
      puts "rgte, version #{RGTE::VERSION}"
    end

    private
    def rules=(file)
      @rules = file
    end
  end
end

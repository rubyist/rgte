require 'optparse'
require File.join(File.dirname(__FILE__), 'rgte', 'rgte_message')
require File.join(File.dirname(__FILE__), 'rgte', 'rgte_blank_message')
require File.join(File.dirname(__FILE__), 'rgte', 'rgte_filter')

module RGTE
  VERSION = '0.0.1'

  class << self
    def application
      @application ||= RGTE::Application.new
    end
  end
end

module RGTE
  class Application
    def initialize
      OptionParser.new do |opts|
        opts.banner = "Usage: rgte [options] < <file>"
        opts.on("-v", "--version", "Print the version") {version; exit}
      end.parse!
    end

    def run
      RGTE::Filter.new(STDIN.read).process!
    end
    
    def version
      puts "rgte, version #{RGTE::VERSION}"
    end
  end
end

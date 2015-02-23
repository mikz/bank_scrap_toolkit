require 'thor'
require 'json'
require 'pp'

module BankScrapToolkit
  class CLI < Thor

    desc 'start mitmproxy', 'ncurses app for recording api calls'
    option :port, type: :numeric, default: 8090
    option :output, type: :string
    option :filter, type: :string

    def mitmproxy
      handle_mitm BankScrapToolkit::Mitmproxy
    end

    desc 'start mitmdump', 'for recording api calls'
    option :port, type: :numeric, default: 8090
    option :output, type: :string, required: true, default: '-'
    option :filter, type: :string

    def mitmdump
      handle_mitm BankScrapToolkit::Mitmdump
    end


    desc 'print FILE', 'file with stored transfers'
    def print(file)
      io = File.open(file, 'r')
      flows = BankScrapToolkit::Flow.parse(io)

      pp flows
    end

    private

    def handle_mitm(klass)
      mitm = klass.new(options[:port], options[:filter])

      Signal.trap('INT') do
        mitm.stop
      end

      mitm.start

      process_output(mitm)
    end

    def output
      case options[:output]
        when '-' then $stdout
        when nil then File.open('/dev/null', 'w')
        else File.open(options[:output], 'w')
      end
    end

    def process_output(mitm)
      flows = mitm.flows
      pp flows

      json = JSON.pretty_generate(flows)
      output.print(json)
    end
  end
end

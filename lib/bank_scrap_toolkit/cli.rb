require 'thor'
require 'json'
require 'pp'
require 'json-schema-generator'

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

    desc 'content FILE INDEX', 'extract INDEXth response content from FILE'
    def content(file, index)
      io = File.open(file, 'r')
      flows = BankScrapToolkit::Flow.parse(io)

      puts flows[index.to_i].response_body
    end

    option :version, type: :string, default: 'draft4'
    desc 'schema FILE', 'generate schema from FILE'
    def schema(file)
      json = JSON::SchemaGenerator.generate file, File.read(file), { schema_version: options[:version] }
      json = JSON.pretty_generate JSON.parse(json)
      puts json
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

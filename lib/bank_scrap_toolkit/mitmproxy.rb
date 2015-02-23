require 'childprocess'
require 'shellwords'

module BankScrapToolkit

  class Mitmproxy


    TEMPLATE = <<-TEMPLATE.freeze
from __future__ import print_function
import json, sys

def start(context, argv):
    context.output = open(argv[1], 'w')
    context.join = None
    print('[', file=context.output)

def done(context):
    print(']', file=context.output)
    context.output.close()

def response(context, flow):
    str = json.dumps(flow.get_state())
    if context.join:
        print(',', file=context.output)
    else:
        context.join = True

    print(str, file=context.output)
    context.output.flush()
TEMPLATE

    COMMAND = 'mitmproxy'.freeze

    def initialize(port, filter = nil)
      @script = ::Tempfile.new('mitmproxy-script')
      @script.write(TEMPLATE)
      @script.close

      @output = ::Tempfile.new('mitmproxy-output')

      @mitmproxy = ::ChildProcess.new(self.class::COMMAND,
                                      '-z',
                                      '-w', @output.path,
                                      '-p', port.to_s,
                                      *Array(filter)
      )

      @mitmproxy.io.inherit!
    end

    def start
      @mitmproxy.start
      @mitmproxy.wait
    rescue Errno::ECHILD
      false
    end

    def flows
      @flows ||= BankScrapToolkit::Flow.parse(output_stream)
    end

    def output_stream
      tmp = Tempfile.new('mitmdump')
      output = ::ChildProcess.new('mitmdump',
                                  '-nr', @output.path,
                                  '-s', "#{@script.path} #{tmp.path}")
      tmp.close
      output.start
      output.wait or raise 'could not export stream'
      tmp.open
    end

    def stop
      @mitmproxy.stop
    end

  end
end

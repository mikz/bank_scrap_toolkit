require 'yajl'

module BankScrapToolkit
  class Flow
    PARSER = Yajl::Parser.new

    REQUEST = 'request'.freeze
    RESPONSE = 'response'.freeze
    METHOD = 'method'.freeze
    HEADERS = 'headers'.freeze
    PATH = 'path'.freeze

    BODY = 'content'.freeze

    REQUEST_KEYS = %w[method path host scheme port headers content].freeze
    RESPONSE_KEYS = %w[code msg headers content ].freeze

    def self.parse(io)
      (PARSER.parse(io) || []).map(&Flow.method(:new))
    end

    def initialize(flow)
      request = flow.fetch('request'.freeze)
      response = flow.fetch('response'.freeze)

      @request = transform(request, REQUEST_KEYS)
      @response = transform(response, RESPONSE_KEYS)
    end

    def to_hash
      {
          request: @request,
          response: @response
      }
    end

    def request_body
      @request.fetch(BODY)
    end

    def request_headers
      @request.fetch(HEADERS)
    end

    def response_headers
      @response.fetch(HEADERS)
    end

    def response_body
      @response.fetch(BODY)
    end

    def request_line
      "#{@request.fetch(METHOD)} #{@request.fetch(PATH)} HTTP/1.1\n"
    end

    def response_line
      "HTTP/1.1 #{@response.fetch('code')} #{@response.fetch('msg')}\n"
    end

    def pretty_print(pp)
      convert_headers = ->(headers) { headers.map{|*v| v.join(': ') }.join("\n") }
      pp.text request_line
      pp.text convert_headers[request_headers]
      pp.text "\n"
      pp.text request_body + "\n"
      pp.text response_line
      pp.text convert_headers[response_headers]
      pp.text "\n"*2
      pp.text response_body
    end

    def to_json(options = {})
      to_hash.to_json(options)
    end

    def transform(message, keys)
      message[HEADERS] = message.fetch(HEADERS).to_h
      keys.zip(message.values_at(*keys)).to_h
    end
  end
end

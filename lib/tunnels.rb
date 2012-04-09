require "tunnels/version"
require "eventmachine"

# most of code is from [thin-glazed](https://github.com/freelancing-god/thin-glazed).
# Copyright © 2012, Thin::Glazed was a Rails Camp New Zealand project, and is developed and maintained by Pat Allan. It is released under the open MIT Licence.

module Tunnels
  def self.run!(from = '127.0.0.1:443', to = '127.0.0.1:80')
    from_host, from_port = parse_host_str(from)
    to_host, to_port = parse_host_str(to)
    puts "#{from_host}:#{from_port} --(--)--> #{to_host}:#{to_port}"

    EventMachine.run do
      EventMachine.start_server(from_host, from_port, HttpsProxy, to_port)
      puts "Ready :)"
    end
  rescue => e
    puts e.message
    puts "Maybe you should run on `sudo`"
  end

  def self.parse_host_str(str)
    raise ArgumentError, 'arg must not be empty' if str.empty?
    parts = str.split(':')
    if parts.size == 1
      ['127.0.0.1', parts[0].to_i]
    else
      [parts[0], parts[1].to_i]
    end
  end

  class HttpClient < EventMachine::Connection
    attr_reader :proxy

    def initialize(proxy)
      @proxy     = proxy
      @connected = EventMachine::DefaultDeferrable.new
    end

    def connection_completed
      @connected.succeed
    end

    def receive_data(data)
      proxy.relay_from_client(data)
    end

    def send(data)
      @connected.callback { send_data data }
    end

    def unbind
      proxy.unbind_client
    end
  end

  class HttpProxy < EventMachine::Connection
    attr_reader :client_port

    def initialize(client_port)
      @client_port = client_port
    end

    def receive_data(data)
      client.send_data data unless data.nil?
    end

    def relay_from_client(data)
      send_data data unless data.nil?
    end

    def unbind
      client.close_connection
      @client = nil
    end

    def unbind_client
      close_connection_after_writing
      @client = nil
    end

    private

    def client
      @client ||= EventMachine.connect '127.0.0.1', client_port, HttpClient, self
    end
  end

  class HttpsProxy < HttpProxy
    def post_init
      start_tls
    end

    def relay_from_client(data)
      super
      @x_forwarded_proto_header_inserted = false
    end

    def receive_data(data)
      if !@x_forwarded_proto_header_inserted && data =~ /\r\n\r\n/
        super data.gsub(/\r\n\r\n/, "\r\nX_FORWARDED_PROTO: https\r\n\r\n")
        @x_forwarded_proto_header_inserted = true
      else
        super
      end
    end
  end
end

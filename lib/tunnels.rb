require "tunnels/version"
require "eventmachine"

# most of code is from [thin-glazed](https://github.com/freelancing-god/thin-glazed).
# Copyright © 2012, Thin::Glazed was a Rails Camp New Zealand project, and is developed and maintained by Pat Allan. It is released under the open MIT Licence.

module Tunnels
  def self.run!(host = '127.0.0.1', from = 443, to = 80)
    EventMachine.run do
      EventMachine.start_server(host, from, HttpsProxy, to)
      puts "Ready :)"
    end
  rescue => e
    puts e.message
    puts "Maybe you should run on `sudo`"
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

    def receive_data(data)
      super data.gsub(/\r\n\r\n/, "\r\nX_FORWARDED_PROTO: https\r\n\r\n")
    end
  end
end

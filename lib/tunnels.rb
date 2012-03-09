require "tunnels/version"
require "eventmachine"
require "yaml"
require "openssl"

# Most of code is from [thin-glazed](https://github.com/freelancing-god/thin-glazed).
# Copyright © 2012, Thin::Glazed was a Rails Camp New Zealand project, and is developed
# and maintained by Pat Allan. It is released under the open MIT Licence.

module Tunnels
  def self.run!(from = '127.0.0.1:443', to = '127.0.0.1:80', config_file = nil)
    from_host, from_port = parse_host_str(from)
    to_host, to_port = parse_host_str(to)
    puts "#{from_host}:#{from_port} --(--)--> #{to_host}:#{to_port}"

    options = parse_config_file config_file

    EventMachine.run do
      EventMachine.start_server(from_host, from_port, HttpsProxy, to_port, options)
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

  def self.parse_config_file(file)
    { "config_file" => file }.merge YAML::load(File.read file) rescue {}
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

    def initialize(client_port, options)
      super client_port

      base_path = File.dirname File.expand_path options['config_file']

      @ssl_options = {
        :cert_chain_file  => File.join(base_path, options['server']['certificate_file']),
        :private_key_file => File.join(base_path, options['server']['private_key_file']),
        :verify_peer      => options['client']['verify']
      }

      # START: Debug
      server_cert = load_cert_file File.join(base_path, options['server']['certificate_file'])
      puts "Server certificate: " + server_cert.subject.to_s
      # END: Debug

      unless options['client']['certificate_ca_file'].nil?
        @ssl_ca = load_cert_file File.join(base_path, options['client']['certificate_ca_file'])
      end
    end

    def post_init
      start_tls @ssl_options
    end

    def receive_data(data)
      header_string = headers.collect { |k, v| k.to_s.upcase + ": " + v }.join "\r\n"

      # START: Debug
      puts "Sending headers:\n" + header_string
      # END: Debug

      super data.gsub(/\r\n\r\n/, "\r\n#{header_string}\r\n\r\n")
    end

    # Called for every certificate in the chain provided by a user if :verify_peer => true was
    # passed to #start_tls.
    # cert - String of the certificate in PEM format.
    def ssl_verify_peer(cert)
      puts "Verify Peer"
      peer = load_cert cert
      verified = peer.verify @ssl_ca.public_key

      # START: Debug
      puts "Issuer subject: " + @ssl_ca.subject.to_s
      puts "Peer issuer:    " + peer.issuer.to_s
      puts "Peer subject:   " + peer.subject.to_s
      puts "Peer verified:  " + verified.inspect
      # END: Debug

      headers[:ssl_client_s_dn] = peer.subject.to_s
      headers[:ssl_client_verify] = if verified then "SUCCESS" else "FAILED" end

      true
    end

    private

    def load_cert(pem_string)
      OpenSSL::X509::Certificate.new(pem_string)
    end

    def load_cert_file(path)
      load_cert File.read(path)
    end

    def headers
      @headers ||= { :x_forwarded_proto => 'https', :ssl_client_verify => 'NONE' }
    end
  end
end

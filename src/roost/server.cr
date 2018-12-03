require "http/server"
require "openssl"
require "./route_handler"
require "./static_file_handler"

module Roost
  class Server
    def initialize(ip_address : String, port : Int, dir : String,
                   certificates : String, private_key : String,
                   ws_uri : String, ws_path : String)
      handlers = [] of (HTTP::ErrorHandler | HTTP::StaticFileHandler | RouteHandler)
      handlers << HTTP::ErrorHandler.new
      handlers << StaticFileHandler.new(dir || ".")
      handlers << RouteHandler.new(ws_path, Server.websocket_handler(ws_uri)) unless ws_uri.empty?

      @server = HTTP::Server.new(handlers)

      if certificates.empty? || private_key.empty?
        @server.bind_tcp(ip_address, port)
      else
        context = OpenSSL::SSL::Context::Server.new
        context.certificate_chain = certificates
        context.private_key = private_key
        @server.bind_tls(ip_address, port, context)
      end
    end

    def listen
      @server.listen
    end

    def close
      @server.close
    end

    def self.run(ip_address, port, dir, certificates = "", private_key = "", ws_uri = "", ws_path = "")
      server = self.new(ip_address, port, dir, certificates, private_key, ws_uri, ws_path)
      server.listen
    end

    def self.websocket_handler(ws_uri : URI | String)
      HTTP::WebSocketHandler.new do |context|
        ws = HTTP::WebSocket.new(ws_uri)
        ws.on_message do |message|
          context.send(message)
        end

        ws.on_close do |message|
          context.close(message)
        end

        context.on_message do |message|
          ws.send(message)
        end

        context.on_close do |message|
          ws.close(message)
        end

        spawn do
          ws.run
        end
      end
    end
  end
end

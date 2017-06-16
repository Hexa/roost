require "http/server"
require "openssl"

module Roost
  class Server
    def self.run(ip_address : String, port : Int, dir = ".", certificates : String = "", private_key : String = "", verbose : Bool = false, websocket : Bool = false, ws_host : String = "::1", ws_port : Int = 8080, ws_path : String = "/")
      handlers = [] of (HTTP::ErrorHandler | HTTP::LogHandler | HTTP::StaticFileHandler | HTTP::WebSocketHandler)
      handlers << HTTP::ErrorHandler.new(verbose)
      handlers << HTTP::LogHandler.new
      handlers << websocket_handler(ws_host, ws_path, ws_port) if websocket
      handlers << HTTP::StaticFileHandler.new(dir)

      server = HTTP::Server.new(ip_address, port, handlers)

      unless certificates.empty? || private_key.empty?
        context = OpenSSL::SSL::Context::Server.new
        context.certificate_chain = certificates
        context.private_key = private_key
        server.tls = context
      end

      server.listen
    end

    def self.websocket_handler(ws_host : String, ws_path : String, ws_port : Int)
      HTTP::WebSocketHandler.new do |context|
        ws = HTTP::WebSocket.new(ws_host, ws_path, ws_port)
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

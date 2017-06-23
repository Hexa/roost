require "http/server"
require "openssl"

module Roost
  class Server
    def initialize(ip_address : String, port : Int, dir : String = ".", certificates : String = "", private_key : String = "", verbose : Bool = false, ws : Bool = false, ws_uri : URI | String = "ws://[::1]:8080/")
      handlers = [] of (HTTP::ErrorHandler | HTTP::LogHandler | HTTP::StaticFileHandler | HTTP::WebSocketHandler)
      handlers << HTTP::ErrorHandler.new(verbose)
      handlers << HTTP::LogHandler.new
      handlers << Roost::Server.websocket_handler(ws_uri) if ws
      handlers << HTTP::StaticFileHandler.new(dir)

      @server = HTTP::Server.new(ip_address, port, handlers)

      unless certificates.empty? || private_key.empty?
        context = OpenSSL::SSL::Context::Server.new
        context.certificate_chain = certificates
        context.private_key = private_key
        @server.tls = context
      end
    end

    def listen
      @server.listen
    end

    def close
      @server.close
    end

    def self.run(ip_address : String, port : Int, dir : String = ".", certificates : String = "", private_key : String = "", verbose : Bool = false, ws : Bool = false, ws_uri : URI | String = "ws://[::1]:8080/")
      server = self.new(ip_address, port, dir, certificates, private_key, verbose, ws, ws_uri)
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

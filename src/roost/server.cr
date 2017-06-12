require "http/server"
require "openssl"

module Roost
  class Server
    def self.run(ip_address : String, port : Int, dir = ".", certificates : String = "", private_key : String = "", verbose : Bool = false, websocket : Bool = false, websocket_host : String = "::1", websocket_port : Int = 18000, websocket_path : String = "/")

      if websocket
        websocket_handler = HTTP::WebSocketHandler.new do |context|
          websocket_client = HTTP::WebSocket.new(websocket_host, websocket_path, websocket_port)
          websocket_client.on_message do |client_message|
            context.send(client_message)
          end

          websocket_client.on_close do |client_message|
            context.close(client_message)
          end

          context.on_message do |message|
            websocket_client.send(message)
          end

          context.on_close do |message|
            websocket_client.close(message)
          end

          spawn do
            websocket_client.run
          end
        end

        handlers = [
          HTTP::ErrorHandler.new(verbose),
          HTTP::LogHandler.new,
          websocket_handler,
          HTTP::StaticFileHandler.new(dir),
        ]
      else
        handlers = [
          HTTP::ErrorHandler.new(verbose),
          HTTP::LogHandler.new,
          HTTP::StaticFileHandler.new(dir),
        ]
      end

      server = HTTP::Server.new(ip_address, port, handlers)

      unless certificates.empty? || private_key.empty?
        context = OpenSSL::SSL::Context::Server.new
        context.certificate_chain = certificates
        context.private_key = private_key
        server.tls = context
      end

      server.listen
    end
  end
end

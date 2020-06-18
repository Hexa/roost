require "http/server"
require "openssl"

module Roost
  class Server
    @server : HTTP::Server

    def initialize(ip_address : String = "::", port : Int = 8080,
                   public_dir : String = ".", ws_uri : String = "",
                   ws_path : String = "/", certificates : String = "",
                   private_key : String = "")
      handlers = [
        HTTP::ErrorHandler.new,
        HTTP::StaticFileHandler.new(public_dir),
        HTTP::WebSocketHandler.new do |websocket, context|
          request = context.request
          if request.path == ws_path
            ws = HTTP::WebSocket.new(ws_uri)
            ws.on_message do |message|
              websocket.send(message)
            end

            ws.on_close do |code, message|
              websocket.close(code, message)
            end

            websocket.on_message do |message|
              ws.send(message)
            end

            websocket.on_close do |code, message|
              ws.close(code, message)
            end

            spawn do
              ws.run
            end
          end
        end,
      ]

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
  end
end

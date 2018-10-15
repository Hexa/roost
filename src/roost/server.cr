require "http/server"
require "openssl"

module Roost
  class Server

    def initialize(ip_address : String, port : Int, dir : String = ".", certificates : String = "", private_key : String = "", ws_uri : String = "", ws_path : String = "")
      handlers = [] of (HTTP::ErrorHandler | HTTP::LogHandler | HTTP::StaticFileHandler | RouteHandler)
      handlers << HTTP::ErrorHandler.new
      handlers << HTTP::LogHandler.new
      handlers << StaticFileHandler.new(dir)
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

    def self.run(ip_address : String, port : Int, dir : String = ".", certificates : String = "", private_key : String = "", ws_uri : String = "", ws_path : String = "")
      server = self.new(ip_address, port, dir, certificates, private_key, ws_uri, ws_path)
      server.listen
    end

    def self.websocket_handler(ws_uri : URI | String) : HTTP::WebSocketHandler
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

  class StaticFileHandler < HTTP::StaticFileHandler
    private def mime_type(path)
      case File.extname(path)
      when ".json"  then "application/json"
      else super(path)
      end
    end
  end

  class RouteHandler
    include HTTP::Handler

    def initialize(path : String, websocket_handler : HTTP::WebSocketHandler)
      @path = path
      @websocket_handler = websocket_handler
    end

    def call(context : HTTP::Server::Context)
      request = context.request
      if (request.path == @path) && request.headers.has_key?("Upgrade") && (request.headers.get("Upgrade")[0] == "websocket")
        @websocket_handler.call(context)
      else
        call_next(context)
      end
    end
  end
end

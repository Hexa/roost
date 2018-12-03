require "http"

module Roost
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

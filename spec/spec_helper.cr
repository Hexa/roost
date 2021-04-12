require "spec"
require "../src/roost/server"

class TestWSClient
  def self.send_receive(uri : URI, message : String) : String
    ch = Channel(String).new
    ws = HTTP::WebSocket.new(uri)
    ws.send(message)
    ws.on_message do |message|
      ch.send message
    end

    spawn do
      ws.run
    end

    message = ch.receive
    ws.close
    message
  end
end

class TestWSServer
  def self.run(host : String, port : Int32, handlers) : HTTP::Server
    server = HTTP::Server.new(handlers)
    server.bind_tcp(host, port)
    spawn do
      server.listen
    end

    server
  end

  def self.run(host : String, port : Int32, handlers, &block)
    server = HTTP::Server.new(handlers)
    server.bind_tcp(host, port)

    spawn do
      server.listen
    end

    yield

    server.close
  end
end

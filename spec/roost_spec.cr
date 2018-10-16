require "./spec_helper"
require "http/client"
require "http/server"
require "http/web_socket"

class TestWSClient
  def self.send_receive(host : String, path : String, port : Int, message : String) : String
    ch = Channel(String).new
    ws = HTTP::WebSocket.new(host, path, port, false)
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
  def self.run(host : String, port : Int, handlers) : HTTP::Server
    server = HTTP::Server.new(handlers)
    server.bind_tcp(host, port)
    spawn do
      server.listen
    end

    server
  end

  def self.run(host : String, port : Int, handlers, &block)
    server = HTTP::Server.new(handlers)
    server.bind_tcp(host, port)

    spawn do
      server.listen
    end

    yield

    server.close
  end
end

describe Roost do
  it "" do
    address = "::"
    port = 8000

    ch = Channel(Roost::Server).new

    spawn do
      server = Roost::Server.new(address, port, ".", "", "", "", "")
      ch.send(server)
      server.listen
    end
    server = ch.receive

    sleep 1

    client = HTTP::Client.new("::1", port)
    client.get("/") do |response|
      response.status_code.should eq(200)
    end

    server.close
  end

  it "" do
    address = "::"
    port = 8000
    ws_host = "::1"
    ws_port = 8001
    ws_path = "/"
    ws_uri = "ws://#{ws_host}:#{ws_port}#{ws_path}"

    ws_handler = HTTP::WebSocketHandler.new do |context|
      context.on_message do |message|
        context.send("message")
      end

      context.on_close do |message|
        context.close("close")
      end
    end

    TestWSServer.run(ws_host, ws_port, [ws_handler]) do
      ch = Channel(Roost::Server).new
      spawn do
        server = Roost::Server.new(address, port, ".", "", "", ws_uri, "/")
        ch.send(server)
        server.listen
      end
      server = ch.receive

      sleep 1
      response_message = TestWSClient.send_receive(ws_host, ws_path, ws_port, "test message")
      response_message.should eq("message")
      server.close
    end
  end
end

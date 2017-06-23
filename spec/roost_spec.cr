require "./spec_helper"
require "http/client"
require "http/server"
require "http/web_socket"

describe Roost do
  it "" do
    address = "::"
    port = 8000

    ch = Channel(Roost::Server).new

    spawn do
      server = Roost::Server.new(address, port)
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

    ws_server = HTTP::Server.new(ws_host, ws_port, [ws_handler])
    spawn do
      ws_server.listen
    end

    ch1 = Channel(Roost::Server).new
    spawn do
      server = Roost::Server.new(address, port, ".", "", "", false, true, ws_uri)
      ch1.send(server)
      server.listen
    end
    server = ch1.receive

    sleep 1

    ch2 = Channel(String).new
    ws = HTTP::WebSocket.new(ws_host, ws_path, ws_port, false)
    ws.send("test message")
    ws.on_message do |message|
      ch2.send message
    end

    spawn do
      ws.run
    end

    message = ch2.receive
    message.should eq("message")

    ws.close
    ws_server.close
    server.close
  end
end

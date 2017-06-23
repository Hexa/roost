require "./spec_helper"
require "http/client"
require "http/server"
require "http/web_socket"

describe Roost do
  it "" do
    address = "::"
    port = 8000

    spawn do
      Roost::Server.run(address, port)
    end

    sleep 1

    client = HTTP::Client.new("::1", port)
    client.get("/") do |response|
      response.status_code.should eq(200)
    end
  end

  it "" do
    address = "::"
    port = 9000
    ws_host = "127.0.0.1"
    ws_port = 9001
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

    server = HTTP::Server.new(ws_host, ws_port, [ws_handler])
    spawn do
      server.listen
    end

    spawn do
      Roost::Server.run(address, port, ".", "", "", false, true, ws_uri)
    end

    sleep 1

    ch = Channel(String).new
    ws = HTTP::WebSocket.new(ws_host, ws_path, ws_port, false)
    ws.send("test message")
    ws.on_message do |message|
      ch.send message
    end

    spawn do
      ws.run
    end

    message = ch.receive
    message.should eq("message")

    ws.close
    server.close
  end
end

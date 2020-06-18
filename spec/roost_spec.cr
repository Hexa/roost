require "./spec_helper"
require "http/client"
require "http/server"
require "http/web_socket"
require "uri"

describe Roost do
  it "" do
    ip_address = "localhost"
    port = 8000

    ch = Channel(Roost::Server).new

    spawn do
      server = Roost::Server.new(ip_address: ip_address, port: port)
      ch.send(server)
      server.listen
    end
    server = ch.receive

    sleep 1

    client = HTTP::Client.new("localhost", port)
    client.get("/") do |response|
      response.status_code.should eq(200)
    end

    server.close
  end

  it "" do
    ip_address = "localhost"
    port = 8000
    ws_uri = URI.new(scheme = "ws", host = "localhost", port = 8001, path = "/")

    ws_handler = HTTP::WebSocketHandler.new do |ws, context|
      ws.on_message do |message|
        ws.send("message")
      end

      ws.on_close do |message|
        ws.close(HTTP::WebSocket::CloseCode::NormalClosure, "close")
      end
    end

    TestWSServer.run(ws_uri.host || "localhost", ws_uri.port || 8001, [ws_handler]) do
      ch = Channel(Roost::Server).new
      spawn do
        server = Roost::Server.new(ip_address: ip_address, port: port, public_dir: ".", ws_uri: ws_uri.to_s)
        ch.send(server)
        server.listen
      end
      server = ch.receive

      sleep 1
      response_message = TestWSClient.send_receive(ws_uri, "test message")
      response_message.should eq("message")
      server.close
    end
  end
end

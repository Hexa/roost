require "./spec_helper"
require "http/client"
require "http/server"
require "http/web_socket"
require "uri"

describe Roost do
  it "" do
    ip_address = "localhost"
    port = 0

    ch = Channel(Roost::Server).new

    spawn do
      server = Roost::Server.new(ip_address: ip_address, port: port)
      ch.send(server)
      server.listen
    end
    server = ch.receive

    5.times do
      break if server.listening?
      sleep 1
    end

    client = HTTP::Client.new("localhost", server.ip_address.port)
    client.get("/") do |response|
      response.status_code.should eq(200)
    end

    server.close
  end

  it "" do
    ip_address = "localhost"
    port = 0
    ws_uri = URI.new("ws", "localhost", 18080, "/")

    ws_handler = HTTP::WebSocketHandler.new do |ws, context|
      ws.on_message do |message|
        ws.send("message")
      end

      ws.on_close do |message|
        ws.close(HTTP::WebSocket::CloseCode::NormalClosure, "close")
      end
    end

    TestWSServer.run(ws_uri.host || "localhost", ws_uri.port || 18080, [ws_handler]) do
      ch = Channel(Roost::Server).new
      spawn do
        server = Roost::Server.new(ip_address: ip_address, port: port, public_dir: ".", ws_uri: ws_uri.to_s)
        ch.send(server)
        server.listen
      end
      server = ch.receive
      ws_uri = URI.new("ws", "localhost", server.ip_address.port, "/")

      5.times do
        break if server.listening?
        sleep 1
      end

      response_message = TestWSClient.send_receive(ws_uri, "test message")
      response_message.should eq("message")
      server.close
    end
  end
end

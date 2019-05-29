require "./spec_helper"
require "http/client"
require "http/server"
require "http/web_socket"

describe Roost do
  it "" do
    ip_address = "::"
    port = 8000

    ch = Channel(Roost::Server).new

    spawn do
      server = Roost::Server.new(ip_address: ip_address, port: port)
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
    ip_address = "::"
    port = 8000
    ws_host = "::1"
    ws_port = 8001
    ws_path = "/"
    ws_uri = "ws://#{ws_host}:#{ws_port}#{ws_path}"

    ws_handler = HTTP::WebSocketHandler.new do |ws, context|
      ws.on_message do |message|
        ws.send("message")
      end

      ws.on_close do |message|
        ws.close("close")
      end
    end

    TestWSServer.run(ws_host, ws_port, [ws_handler]) do
      ch = Channel(Roost::Server).new
      spawn do
        server = Roost::Server.new(ip_address: ip_address, port: port, public_dir: ".", ws_uri: ws_uri)
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

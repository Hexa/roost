require "./spec_helper"
require "http/client"

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
end

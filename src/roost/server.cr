require "http/server"
require "openssl"

module Roost
  class Server
    def self.run(ip_address : String, port : Int, dir = ".", certificates = "", private_key = "")
      server = HTTP::Server.new(ip_address, port, [
        HTTP::LogHandler.new,
        HTTP::StaticFileHandler.new(dir),
      ])

      unless certificates.empty? || private_key.empty?
        context = OpenSSL::SSL::Context::Server.new
        context.certificate_chain = certificates
        context.private_key = private_key
        server.tls = context
      end

      server.listen
    end
  end
end

require "./roost/*"
require "option_parser"
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

address = "0.0.0.0"
port = 8000
dir = "."
certificates = ""
private_key = ""

OptionParser.parse! do |parser|
  parser.banner = "Usage: roost [arguments]"
  parser.on("-a ADDRESS", "address") { |name| address = name }
  parser.on("-p PORT", "port") { |name| port = name.to_i }
  parser.on("-d DIR", "root directory") { |name| dir = name }
  parser.on("-c FILE", "certificates") { |name| certificates = name }
  parser.on("-k KEY", "private key") { |name| private_key = name }
  parser.on("-h", "Show this help") do
    puts parser
    exit 1
  end
  parser.missing_option { exit 1 }
  parser.invalid_option { exit 255 }
end

Roost::Server.run(address, port, dir, certificates, private_key)

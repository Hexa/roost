require "./roost/*"
require "option_parser"
require "http/server"

module Roost
  class Server
    def self.run(ip_address : String, port : Int, dir = ".")
      HTTP::Server.new(ip_address, port, [
        HTTP::LogHandler.new,
        HTTP::StaticFileHandler.new(dir),
      ]).listen
    end
  end
end

address = "0.0.0.0"
port = 8000
dir = "."

OptionParser.parse! do |parser|
  parser.banner = "Usage: Roost [arguments]"
  parser.on("-a ADDRESS", "address") { |name| address = name }
  parser.on("-p PORT", "port") { |name| port = name.to_i }
  parser.on("-d DIR", "root directory") { |name| dir = name }
  parser.on("-h", "Show this help") do
    puts parser
    exit 1
  end
  parser.missing_option { exit 1 }
  parser.invalid_option { exit 255 }
end

Roost::Server.run(address, port, dir)

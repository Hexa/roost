require "./roost/*"
require "option_parser"

address = "::"
port = 8000
dir = "."
certificates = ""
private_key = ""
verbose = false
websocket = false
websocket_host = "::1"
websocket_port = 18000
websocket_path = ""

OptionParser.parse! do |parser|
  parser.banner = "Usage: roost [arguments]"
  parser.on("-a ADDRESS", "address") { |name| address = name }
  parser.on("-p PORT", "port") { |name| port = name.to_i }
  parser.on("-d DIR", "root directory") { |name| dir = name }
  parser.on("-c FILE", "certificates") { |name| certificates = name }
  parser.on("-k KEY", "private key") { |name| private_key = name }
  parser.on("-v", "verbose") { verbose = true }
  parser.on("-f HOST", "websocket host") { |name| websocket_host = name }
  parser.on("-q PORT", "websocket port") { |name| websocket_port = name.to_i }
  parser.on("-w PATH", "websocket path") { |name| websocket_path = name; websocket = true }
  parser.on("-h", "Show this help") do
    puts parser
    exit 1
  end
  parser.missing_option { exit 1 }
  parser.invalid_option { exit 255 }
end

Roost::Server.run(address, port, dir, certificates, private_key, verbose, websocket, websocket_host, websocket_port, websocket_path)

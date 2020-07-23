require "../src/roost"
require "option_parser"
require "uri"

ip_address = "::"
port = 8000
public_dir = "."
certificates = ""
private_key = ""
ws_uri = ""
ws_path = "/"

OptionParser.parse do |parser|
  parser.banner = "Usage: roost [arguments]"
  parser.on("-l ADDRESS", "--listening-address ADDRESS", "listening address") { |name| ip_address = name }
  parser.on("-p PORT", "--listening-port PORT", "listening port") { |name| port = name.to_i }
  parser.on("-d DIR", "--document-root DIR", "document root") { |name| public_dir = name }
  parser.on("-c FILE", "--certificates FILE", "certificate file") { |name| certificates = name }
  parser.on("-k KEY", "--private-key KEY", "private key file") { |name| private_key = name }
  parser.on("-w URI", "--websocket-uri URI", "websocket uri") { |name| ws_uri = name }
  parser.on("--websocket-path PATH", "websocket path") { |name| ws_path = name }
  parser.on("-V", "--version", "version") { puts Roost::VERSION; exit 0 }
  parser.on("-h", "--help", "Show this help") do
    puts parser
    exit 1
  end
  parser.missing_option { exit 1 }
  parser.invalid_option { exit 255 }
end

server = Roost::Server.new(ip_address, port, public_dir, ws_uri, ws_path, certificates, private_key)
server.listen

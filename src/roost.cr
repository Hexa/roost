require "./roost/*"
require "option_parser"
require "uri"

address = "::"
port = 8000
dir = "."
certificates = ""
private_key = ""
verbose = false
ws = false
ws_uri = URI.parse("ws://[::1]:8080")

OptionParser.parse! do |parser|
  parser.banner = "Usage: roost [arguments]"
  parser.on("-l ADDRESS", "--listening-address ADDRESS", "listening address") { |name| address = name }
  parser.on("-p PORT", "--listening-port PORT", "listening port") { |name| port = name.to_i }
  parser.on("-d DIR", "--document-root DIR", "document root") { |name| dir = name }
  parser.on("-c FILE", "--certificates FILE", "certificate file") { |name| certificates = name }
  parser.on("-k KEY", "--private-key KEY", "private key file") { |name| private_key = name }
  parser.on("-w URI", "--websocket-uri URI", "websocket URI") { |name| ws_uri = name; ws = true }
  parser.on("-v", "--verbose", "verbose") { verbose = true }
  parser.on("-V", "--version", "version") { puts Roost::VERSION; exit 0 }
  parser.on("-h", "--help", "Show this help") do
    puts parser
    exit 1
  end
  parser.missing_option { exit 1 }
  parser.invalid_option { exit 255 }
end

Roost::Server.run(address, port, dir, certificates, private_key, verbose, ws, ws_uri)

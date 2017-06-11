require "./roost/*"
require "option_parser"

address = "::"
port = 8000
dir = "."
certificates = ""
private_key = ""
verbose = false

OptionParser.parse! do |parser|
  parser.banner = "Usage: roost [arguments]"
  parser.on("-a ADDRESS", "address") { |name| address = name }
  parser.on("-p PORT", "port") { |name| port = name.to_i }
  parser.on("-d DIR", "root directory") { |name| dir = name }
  parser.on("-c FILE", "certificates") { |name| certificates = name }
  parser.on("-k KEY", "private key") { |name| private_key = name }
  parser.on("-v", "verbose") { verbose = true }
  parser.on("-h", "Show this help") do
    puts parser
    exit 1
  end
  parser.missing_option { exit 1 }
  parser.invalid_option { exit 255 }
end

Roost::Server.run(address, port, dir, certificates, private_key, verbose)

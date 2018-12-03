require "http/server"

module Roost
  class StaticFileHandler < HTTP::StaticFileHandler
    private def mime_type(path)
      case File.extname(path)
      when ".json" then "application/json"
      else              super(path)
      end
    end
  end
end


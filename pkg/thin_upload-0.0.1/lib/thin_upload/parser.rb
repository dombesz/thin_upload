module Thin
  class Request
    def new_parse(data)
      success = thin_parse(data)

      @uuid ||= data.scan(/uuid\"\r\n\r\n(.*)\r/i).flatten.first
      # puts "LOG - #{@uuid}"
      @size ||= 0
      @size += data.size
      progress = @size>content_length ? 100: (@size/content_length.to_f)*100
      Thin::Server::progress[@uuid] = [progress, finished?] if @uuid
      @env.merge!('rack.progress' => Thin::Server::progress.clone) if finished?
      @req_uuid = data.scan(/uuid=(.*) /).flatten.first
      Thin::Server::progress.delete(@req_uuid) if @req_uuid && finished? && Thin::Server::progress[@req_uuid] && Thin::Server::progress[@req_uuid][1]
      success
    end
    
    alias_method :thin_parse, :parse
    alias_method :parse, :new_parse
    
  end
end
module Thin
  class Server
    def self.progress
      @@progress||={}
    end  
  end
end
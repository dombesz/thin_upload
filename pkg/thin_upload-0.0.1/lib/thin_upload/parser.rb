module Thin
  class Request
    def new_parse(data)
      success = thin_parse(data)
      #scanning for the upload uuid id,which is sent with the file
      @uuid ||= data.scan(/uuid\"\r\n\r\n(.*)\r/i).flatten.first
      #storing the actual parsed size to track progress
      @size ||= 0
      @size += data.size
      progress = @size>content_length ? 100: ((@size/content_length.to_f)*100).to_i
      #storing the progress with the uiid
      Thin::Server::progress[@uuid] = progress if @uuid
      #merging the progress hash into the environment, so canbe accessed via request.env['rack.progress'] in the app
      @env.merge!('rack.progress' => Thin::Server::progress.clone) if finished?
      #deleting the progress from the hash if the uplaod is finished and the result also was requested
      @req_uuid = data.scan(/uuid=(.*) /).flatten.first
      Thin::Server::progress.delete(@req_uuid) if @req_uuid && finished? && Thin::Server::progress[@req_uuid] && Thin::Server::progress[@req_uuid] >= 100# && Thin::Server::progress[@req_uuid][1]
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
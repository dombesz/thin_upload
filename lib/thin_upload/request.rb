#Thin module from thin server
module Thin
  # The Request class takes part of the Thin module which is responsible
  # for incomming web requests for thin server.
  # The class is opened up here for adding functionality to track 
  # progress of file uploads.
  
  class Request
    #Freeze Rack header for progress hash
    RACK_PROGRESS = 'rack.progress'.freeze
        
    #Freeze some regexps
    #regexp to identify file upload
    POST_REQUEST_REGEXP = /uuid\"\r\n\r\n(.*)\r/i.freeze
    #regexp to identify upload progress requests 
    GET_REQUEST_REGEXP = /uuid=(.*) /.freeze
    attr_reader :parser
    attr_accessor :data_buffer
    
    # +new_parse+ method extends the original +parse+ method's
    # functionality with the upload progress tracking
    # Arguments:
    #  data: (String) 
    
    def new_parse(data)
      scan_content(data) unless uuid_found_or_limit_reached?
      success = thin_parse(data) #execute the the original +parse+ method
      store_progress(@upload_uuid)
      cleanup_progress_hash(@request_uuid)
      success #returns the result from Thin's parse method
    end

    # The +Thin+'s +parse+ method is aliased to +thin_parse+
    # and the +new_parse+ method is aliased to +parse+
    alias_method :thin_parse, :parse
    alias_method :parse, :new_parse    

    # Scans unparsed data for uuids, the unparsed data 
    # is stored in a string for buffering purposes
    # which is deleted after the uuid has been found.
    # Arguments:
    #  data: (String)

    def scan_content(data)
      @data_buffer = @data_buffer.to_s + data
      @upload_uuid  ||= @data_buffer.scan(POST_REQUEST_REGEXP).flatten.first
      @request_uuid ||= @data_buffer.scan(GET_REQUEST_REGEXP).flatten.first
    end
    
    # Checking if we still have to search for uuid's
    # Arguments:
    #  none
    def uuid_found_or_limit_reached?
      if @upload_uuid || @request_uuid || (body.size > MAX_BODY)
        @data_buffer = nil
        true
      else
        false
      end
    end

    # Calculating the progress based on +content_length+ and received body size +body.size+
    # Arguments:
    #  none
    def progress
      ((body.size/content_length.to_f)*100).to_i
    end
    
    # progress can be accessed via +request.env['rack.progress']+ in the app
    # Arguments:
    #  uuid: (String) 
    def store_progress(uuid)
      Thin::Server::progress[uuid] = progress if uuid #storing the progress with the uiid
      @env.merge!(RACK_PROGRESS=>Thin::Server::progress.clone) if finished? #merging the progress hash into the environment
    end
    
    # deleting progress entry from +Thin::Server::progress+ if the upload is finished and the result was requested
    # Arguments:
    #  data: (String) 
    def cleanup_progress_hash(req_uuid)
      Thin::Server::progress.delete(req_uuid) if Thin::Server::progress[req_uuid] == 100 && finished?#delete when progress is returned and 100%
    end
  end
end
module Thin
  # Thin's server class
  class Server
    #adding a hash to store all the upload progress in the server
    def self.progress
      @@progress||={}
    end  
  end
end
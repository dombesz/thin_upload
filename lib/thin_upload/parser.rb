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
    UPLOAD_REQUEST_REGEXP = /uuid\"\r\n\r\n(.*)\r/i.freeze
    #regexp to identify upload progress requests 
    PROGRESS_REQUEST_REGEXP = /uuid=(.*) /.freeze
        
    # +new_parse+ method extends the original +parse+ method's
    # functionality with the upload progress tracking
    # Arguments:
    #  data: (String) 
    
    def new_parse(data)
      success = thin_parse(data) #execute the the original +parse+ method
      uuid = scan_uuid(data)
      progress = calculate_progress(data.size) if uuid
      store_progress(uuid, progress)      
      cleanup_progress_hash(data)
      success #returns the result from Thin's parse method
    end

    # The +Thin+'s +parse+ method is aliased to +thin_parse+
    # and the +new_parse+ method is aliased to +parse+
    alias_method :thin_parse, :parse
    alias_method :parse, :new_parse    

    #TODO: Check if these methods can be hidden from the original +Request+ class

    # Check if the request needs progress tracking
    # Arguments:
    #  data: (String) 
    def scan_uuid(data)
      @upload_uuid ||= data.scan(UPLOAD_REQUEST_REGEXP).flatten.first
    end
    
    # Calculating the progress based on +content_length+ and received body size +@received_size+
    # Arguments:
    #  size: (Integer) 
    def calculate_progress(size)
      @received_size = @received_size.to_i + size #adding received chunk size to received size
      @received_size > content_length ? 100 : ((@received_size/content_length.to_f)*100).to_i
    end
    
    #progress can be accessed via +request.env['rack.progress']+ in the app
    # Arguments:
    #  uuid: (String) 
    #  progress: (Integer)     
    def store_progress(uuid, progress)
      Thin::Server::progress[uuid] = progress if uuid #storing the progress with the uiid
      @env.merge!(RACK_PROGRESS=>Thin::Server::progress.clone) if finished? #merging the progress hash into the environment
    end
    
    # deleting progress entry from +Thin::Server::progress+ if the upload is finished and the result was requested
    # Arguments:
    #  data: (String) 
    def cleanup_progress_hash(data)
      req_uuid = data.scan(PROGRESS_REQUEST_REGEXP).flatten.first #check if we got a progress request
      Thin::Server::progress.delete(req_uuid) if Thin::Server::progress[req_uuid] == 100 && finished? #delete when progress is returned and 100%
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
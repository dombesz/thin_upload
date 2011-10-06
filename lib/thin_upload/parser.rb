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
      store_progress(uuid, calculate_progress) if uuid
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
       @upload_uuid ||= scan_body(UPLOAD_REQUEST_REGEXP)
    end

    # Scans the received body for the desired regex
    # Arguments:
    #   regexp: (Regexp or String)
    def scan_body(regexp)
      if body.size < MAX_BODY #limiting scanning length to avoid performance hit
        original_pos = body.pos #storing current body position
        body.rewind #rewinding body 
        result = body.read.scan(regexp).flatten.first
        body.seek(original_pos) #seeking back to original position
      end
      result
    end
    
    # Calculating the progress based on +content_length+ and received body size +@received_size+
    # Arguments:
    #  none
    def calculate_progress
      ((body.size/content_length.to_f)*100).to_i
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
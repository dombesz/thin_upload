require 'test/unit'
require 'thin'
require 'thin_upload/parser'

def upload_data_string
  "form-data; name=\"uuid\"\r\n\r\n#{uuid}\r\n-----------------------------"
end

def uuid
  "2ce89350-cb31-012e-dc4a-64b9e8c7c202"
end

# Create and parse a request
def new_request(data)
  request = Thin::Request.new
  request.parse(data)
  request
end
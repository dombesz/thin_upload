require 'test/unit'
require 'thin'
require 'thin_upload'

def upload_data_string
  "form-data; name=\"uuid\"\r\n\r\n#{uuid}\r\n-----------------------------"
end

def post_request(body)
  "POST / HTTP/1.1\r\nHost: localhost\r\nContent-Type: text/html\r\nContent-Length: #{body.size}\r\n\r\n#{body}"
end

def big_post_request(body)
  "POST / HTTP/1.1\r\nHost: localhost\r\nContent-Type: text/html\r\nContent-Length: #{Thin::Request::MAX_BODY+1}\r\n\r\n#{body}"
end
def get_request(url)
  "GET #{url} HTTP/1.1\r\nHost: localhost:3000\r\n\r\n"
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
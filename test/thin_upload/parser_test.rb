require 'test_helper'

class ParserTest < Test::Unit::TestCase
  
  def setup
    body = "POST / HTTP/1.1\r\nHost: localhost\r\nContent-Type: text/html\r\nContent-Length: 100\r\n\r\n#{"a"*100}"
    @request = new_request(body)
  end
  
  def test_scan_uuid
    assert_equal @request.scan_uuid(upload_data_string), uuid
  end  
  
  def test_calculate_progress
    assert_equal @request.instance_variable_get(:@received_size), nil
    assert_equal @request.calculate_progress(10), 10
    assert_equal @request.calculate_progress(50), 60
    assert_equal @request.calculate_progress(40), 100
  end
  
  def test_calculate_progress_should_be_limited
    assert_equal @request.calculate_progress(110), 100
  end
  
  def test_store_progress
    @request.store_progress(uuid, 50)
    assert_equal Thin::Server::progress[uuid], 50
  end
  
  def test_progress_is_returned_on_parse_finish
    assert @request.finished?
    @request.store_progress(uuid, 50)
    assert_equal @request.env[Thin::Request::RACK_PROGRESS][uuid], 50
  end
  
  def test_progress_is_deleted_when_it_was_finished_and_requested
    @request.store_progress(uuid, 100)
    @request.parse("POST / HTTP/1.1\r\nHost: localhost\r\nContent-Type: text/html\r\nContent-Length: 42\r\n\r\nuuid=#{uuid} ")
    assert_equal Thin::Server::progress, {}
  end
  
  def test_progress_is_returned_when_its_finished_and_not_was_requested_yet
    @request.store_progress(uuid, 100)
    @request.parse("POST / HTTP/1.1\r\nHost: localhost\r\nContent-Type: text/html\r\nContent-Length: 42\r\n\r\nuuid=#{uuid} ")
    assert_equal @request.env[Thin::Request::RACK_PROGRESS][uuid], 100
  end
end
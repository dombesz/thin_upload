require 'test_helper'

class RequestTest < Test::Unit::TestCase
  
  def setup
    @request = new_request(post_request("a"*100))
  end

  def test_scan_uuid_on_url_request
    @request.scan_content(get_request("?uuid=#{uuid}"))
    assert_equal @request.instance_variable_get(:@request_uuid), uuid
  end  
  
  def test_scan_uuid_on_form_request
    @request.scan_content(upload_data_string)
    assert_equal @request.instance_variable_get(:@upload_uuid), uuid
  end  


  def test_store_data_in_buffer
    content  = "content"
    content2 = "content2"
    @request.parse(content)
    assert @request.data_buffer.match(/#{content}$/)
    @request.parse(content2)
    assert @request.data_buffer.match(/#{content+content2}$/)
  end
  
  def test_clear_data_from_buffer_when_url_uuid_found
    content  = "content"
    @request.parse(content)
    assert @request.data_buffer.match(/#{content}$/)
    @request.parse(get_request("?uuid=#{uuid}"))
    assert_equal @request.instance_variable_get(:@request_uuid), uuid
    @request.parse content
    assert_equal @request.data_buffer, nil
  end
  
  def test_clear_data_from_buffer_when_form_uuid_found
    content  = "content"
    @request.parse(content)
    assert @request.data_buffer.match(/#{content}$/)
    @request.parse post_request(upload_data_string)
    assert_equal @request.instance_variable_get(:@upload_uuid), uuid
    @request.parse content
    assert_equal @request.data_buffer, nil
  end

  def test_stop_parsing_when_url_uuid_found
    assert !@request.uuid_found_or_limit_reached?
    @request.scan_content(get_request("?uuid=#{uuid}"))
    assert @request.uuid_found_or_limit_reached?
  end  
  
  def test_stop_parsing_when_form_uuid_found
    assert !@request.uuid_found_or_limit_reached?
    @request.scan_content(upload_data_string)
    assert @request.uuid_found_or_limit_reached?
  end  

  def test_should_stop_parsing_when_body_size_limit_reached
    @request = new_request(post_request("a"))
    assert !@request.uuid_found_or_limit_reached?
    @request.body << "a" * (Thin::Request::MAX_BODY+1)
    assert @request.uuid_found_or_limit_reached?
    assert_equal @request.instance_variable_get(:@data_buffer), nil
  end

  def test_calculate_progress
    @request.instance_variable_set(:@body, "a"*20)
    assert_equal @request.progress, 20
    @request.instance_variable_set(:@body, "a"*45)
    assert_equal @request.progress, 45
    @request.instance_variable_set(:@body, "a"*100)
    assert_equal @request.progress, 100
  end
    
  def test_store_progress
    @request.instance_variable_set(:@body, "a"*50)
    @request.store_progress(uuid)
    assert_equal Thin::Server::progress[uuid], 50    
  end
  
  def test_progress_is_returned_on_parse_finish
    Thin::Server::progress['my_id'] = 45
    assert @request.finished?
    @request.store_progress(uuid)
    assert_equal @request.env[Thin::Request::RACK_PROGRESS]['my_id'], 45
  end
  
  def test_progress_is_deleted_when_it_was_finished_and_requested
    Thin::Server::progress[uuid] = 100
    assert @request.parse post_request("uuid=#{uuid} ")
    assert_equal @request.env[Thin::Request::RACK_PROGRESS][uuid], 100
  end
  
  def test_progress_is_returned_when_its_finished_and_not_was_requested_yet
    Thin::Server::progress[uuid] = 100
    @request = Thin::Request.new
    assert @request.parse(get_request("/progress?uuid=#{uuid}"))
    assert_equal Thin::Server::progress.has_key?(uuid), false
  end
     
end
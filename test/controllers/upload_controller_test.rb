require 'test_helper'

class UploadControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get upload_index_url
    assert_response :success
  end

end

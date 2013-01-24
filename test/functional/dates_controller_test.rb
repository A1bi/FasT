require 'test_helper'

class DatesControllerTest < ActionController::TestCase
  test "should get jedermann" do
    get :jedermann
    assert_response :success
  end

end

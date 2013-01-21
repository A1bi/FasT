require 'test_helper'

class GbookControllerTest < ActionController::TestCase
  test "should get entries" do
    get :entries
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

end

require 'test_helper'

class AccountsControllerTest < ActionController::TestCase
  test "should get my_account" do
    get :my_account
    assert_response :success
  end

  test "should get purchases" do
    get :purchases
    assert_response :success
  end

end

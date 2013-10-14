require 'spec_helper'

describe AccountsController do
  describe '/account' do
    it 'requires login' do
      get :show
      assert_redirected_to login_path
    end

    it "loads successfully" do
      sign_in(create(:verified_user))
      get :show
      assert_response :success
    end
  end
end

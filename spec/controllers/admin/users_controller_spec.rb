require 'spec_helper'

describe Admin::UsersController do
  let(:user) { create(:verified_user) }

  before do
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV["ADMIN_USERNAME"], ENV["ADMIN_PASSWORD"])
  end

  describe '/activate' do
    it "should redirect to nid clusters page" do
      post :activate, :id => user.id
      assert_redirected_to admin_nid_reviews_path
    end

    it "should activate user" do
      User.any_instance.should_receive(:activate!)
      post :activate, :id => user.id
    end

    it "should email notification" do
      post :activate, :id => user.id
      email_deliveries.count.should eq 1
    end
  end

  describe '/deactivate' do
    it "should redirect to nid clusters page" do
      post :deactivate, :id => user.id
      assert_redirected_to admin_nid_reviews_path
    end

    it "should deactivate user" do
      User.any_instance.should_receive(:deactivate!)
      post :deactivate, :id => user.id
    end

    it "should email notification" do
      post :deactivate, :id => user.id
      email_deliveries.count.should eq 1
    end
  end

  describe '/csv' do
    it "should load successfully" do
      get :csv
      assert_response :success
    end
  end
end

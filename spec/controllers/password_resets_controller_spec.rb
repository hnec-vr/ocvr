require 'spec_helper'

describe PasswordResetsController do
  describe "/new" do
    it "should load successfully" do
      get :new
      assert_response :success
    end
  end

  describe '/create' do
    let!(:user) { create(:verified_user) }

    it "should email reset link" do
      post :create, :email => user.email
      email_deliveries.count.should eq 1
    end

    it "should regenerate password reset token" do
      User.any_instance.should_receive(:regenerate_password_reset_token!)
      User.any_instance.stub(:password_reset_token => "123")

      post :create, :email => user.email
    end

    it "should redirect to page telling user email has been sent" do
      post :create, :email => user.email
      assert_redirected_to sent_password_resets_path
    end

    it "should re-render form if email not found" do
      post :create, :email => "foo@bar.com"
      assert_response :success
      assert_template :new
    end
  end

  describe '/sent' do
    it "should load successfully" do
      get :sent
      assert_response :success
    end
  end

  describe '/edit' do
    let!(:user) { create(:verified_user, :password_reset_token => SecureRandom::hex(32)) }

    it "should only accessible via a valid token" do
      get :edit, :id => user.password_reset_token
      assert_response :success
    end

    it "should redirect home if invalid token" do
      get :edit, :id => "badtoken"
      assert_redirected_to root_path
    end
  end

  describe '/update' do
    let!(:user) { create(:verified_user, :password_reset_token => SecureRandom::hex(32)) }

    it "should update user" do
      User.any_instance.should_receive(:save).and_return(user)

      put :update, :id => user.password_reset_token,
                   :user => {:password => "newpassword",
                             :password_confirmation => "newpassword"}
    end

    it "should redirect to login page if successful" do
      put :update, :id => user.password_reset_token,
                   :user => {:password => "newpassword",
                             :password_confirmation => "newpassword"}
      assert_redirected_to login_path
    end

    it "should render edit page if not successful" do
      put :update, :id => user.password_reset_token,
                   :user => {:password => "newpassword"}
      assert_template :edit
    end
  end
end

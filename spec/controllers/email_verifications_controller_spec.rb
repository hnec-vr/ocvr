require 'spec_helper'

describe EmailVerificationsController do
  let(:user) { FactoryGirl.create(:user) }

  it "should verify email" do
    User.any_instance.should_receive(:verify_email!)
    get :verify, :token => user.email_verification_token
  end

  it "should redirect to login" do
    get :verify, :token => user.email_verification_token
    assert_redirected_to login_path
  end

  it "should redirect home if token is invalid" do
    get :verify, :token => 1
    assert_redirected_to root_path
  end
end

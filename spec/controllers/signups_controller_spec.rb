require 'spec_helper'

describe SignupsController do
  describe 'viewing signup page' do
    before { get :new }

    it { assert_response :success }
  end

  describe 'submitting signup form with invalid input' do
    before { post :create }

    it { assert_response :success }
    it { assert_template(:new) }
  end

  describe 'signing up successfully' do
    before { post :create, :user => FactoryGirl.attributes_for(:user) }
    it "should send email verification email" do
      email_deliveries.count.should eq 1
    end

    it { assert_redirected_to confirm_path }
  end
end

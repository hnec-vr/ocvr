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

  describe "should redirect to /closed if voter reg is closed" do
    it "#new" do
      Date.stub(:today => ::SETTINGS[:voter_registration_deadline]+1.day)
      get :new
      assert_redirected_to closed_path
    end

    it "#post" do
      Date.stub(:today => ::SETTINGS[:voter_registration_deadline]+1.day)
      post :create, :user => FactoryGirl.attributes_for(:user)
      assert_redirected_to closed_path
    end
  end
end

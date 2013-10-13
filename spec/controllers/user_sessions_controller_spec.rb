require 'spec_helper'

describe UserSessionsController do
  describe '/login' do
    before { get :new }
    it { assert_response :success }
  end

  context 'signing in' do
    let(:user) { create(:verified_user) }
    before { post :create, :user_session => {:email => user.email, :password => user.password} }

    it { assert_redirected_to account_path }
  end

  context 'attempting sign in before email verification' do
    let(:user) { create(:user) }
    before { post :create, :user_session => {:email => user.email, :password => user.password} }

    it { assert_not_nil assigns(:failed_login) }
    it { assert_response :success }
    it { assert_template(:new) }
  end

  context 'signing in with invalid credentials' do
    before { post :create }
    it { assert_not_nil assigns(:failed_login) }
    it { assert_response :success }
    it { assert_template(:new) }
  end
end

require 'spec_helper'

describe StaticPagesController do
  describe '/nonid' do
    before { get :nonid }
    it { assert_response :success }
  end

  describe '/faq' do
    before { get :faq }
    it { assert_response :success }
  end

  describe '/start' do
    before { get :start }
    it { assert_response :success }
  end

  describe '/confirm' do
    before { get :confirm }
    it { assert_response :success }
  end

  describe '/suspended' do
    before { get :suspended }
    it { assert_response :success }
  end
end

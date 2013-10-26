require 'spec_helper'

describe Admin::NidReviewsController do
  context "when unauthenticated" do
    it "should send 401 status" do
      get :index
      assert_response 401
    end
  end

  context "when authenticated" do
    before do
      request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV["ADMIN_USERNAME"], ENV["ADMIN_PASSWORD"])
    end

    describe "/index" do
      it "should load successfully" do
        get :index
        assert_response :success
      end
    end

    describe "/approve" do
      let!(:user) { create(:user_with_nid, :national_id => successful_response[:body]["national_id"]) }
      let!(:nid_review) { create(:nid_review, :nid_data => successful_response[:body]) }

      it "should approve nid review" do
        NidReview.any_instance.should_receive(:approve!)
        post :approve, :id => nid_review.id
      end

      it "should redirect to index" do
        NidReview.any_instance.stub(:approve!)
        post :approve, :id => nid_review.id
        assert_redirected_to admin_nid_reviews_path
      end

      it "should send email notifications" do
        post :approve, :id => nid_review.id
        email_deliveries.count.should eq 1
      end
    end

    describe "/deny" do
      let!(:user) { create(:user_with_nid, :national_id => successful_response[:body]["national_id"]) }
      let!(:nid_review) { create(:nid_review, :nid_data => successful_response[:body]) }

      it "should approve nid review" do
        NidReview.any_instance.should_receive(:deny!)
        post :deny, :id => nid_review.id
      end

      it "should redirect to index" do
        NidReview.any_instance.stub(:deny!)
        post :deny, :id => nid_review.id
        assert_redirected_to admin_nid_reviews_path
      end

      it "should send email notification" do
        post :deny, :id => nid_review.id
        email_deliveries.count.should eq 1
      end
    end
  end
end

require 'spec_helper'

describe NidReview do
  it { should belong_to :user }
  it { should validate_presence_of :user_id }
  it { should validate_presence_of :registry_number }
  it { should validate_presence_of :mother_name }
  it { should validate_presence_of :nid_data }
  it { should serialize :nid_data }

  let!(:nid_review) { create(:nid_review, :nid_data => successful_response[:body]) }

  describe "processed?" do
    it "should be false by default" do
      nid_review.processed?.should be_false
    end

    it "should be true if approved" do
      nid_review.stub(:approved => true)
      nid_review.processed?.should be_true
    end

    it "should be true if denied" do
      nid_review.stub(:approved => false)
      nid_review.processed?.should be_true
    end
  end

  describe "#deny!" do
    it "sets approved to false" do
      nid_review.deny!
      nid_review.reload.approved.should be_false
    end
  end

  describe "#approve!" do
    it "sets approved to true" do
      nid_review.approve!
      nid_review.reload.approved.should be_true
    end

    it "sends #claim_nid! to user" do
      User.any_instance.should_receive(:claim_nid!)
      nid_review.approve!
    end
  end
end

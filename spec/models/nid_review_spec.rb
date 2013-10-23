require 'spec_helper'

describe NidReview do
  it { should belong_to :user }
  it { should validate_presence_of :user_id }
  it { should validate_presence_of :registry_number }
  it { should validate_presence_of :mother_name }
  it { should validate_presence_of :nid_data }
  it { should serialize :nid_data }

  let!(:user) { create(:user_with_nid, :national_id => successful_response[:body]["national_id"]) }
  let!(:nid_review) { create(:nid_review, :nid_data => successful_response[:body]) }

  it "should automatically set original user" do
    nid_review.original_user.should eq user
  end

  it "should require original user" do
    user.update_attribute(:national_id, nil)
    nid_review = build(:nid_review, :nid_data => successful_response[:body])
    nid_review.valid?.should be_false
  end

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

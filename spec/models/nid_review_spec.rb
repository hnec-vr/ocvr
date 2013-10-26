require 'spec_helper'

describe NidReview do
  it { should belong_to :user }
  it { should validate_presence_of :user_id }
  it { should validate_presence_of :national_id  }
  it { should validate_presence_of :registry_number }
  it { should validate_presence_of :mother_name }
  it { should validate_presence_of :nid_data }
  it { should serialize :nid_data }

  let!(:user) { create(:user_with_nid, :national_id => successful_response[:body]["national_id"]) }
  let!(:nid_review) { create(:nid_review, :nid_data => successful_response[:body]) }

  it "should automatically set national_id" do
    nid_review.national_id.should eq nid_review.nid_data["national_id"]
  end

  describe "processed?" do
    it "should be false by default" do
      nid_review.processed?.should be_false
    end
  end

  describe "#deny!" do
    it "sets approved to false" do
      nid_review.deny!
      nid_review.reload.verdict.should eq "denied"
    end
  end

  describe "#approve!" do
    it "sets approved to true" do
      nid_review.approve!
      nid_review.reload.verdict.should eq "approved"
    end

    it "sends #activate! to user" do
      User.any_instance.should_receive(:update_attributes)
      nid_review.approve!
    end
  end
end

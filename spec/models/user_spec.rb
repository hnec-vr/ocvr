require 'spec_helper'

describe User do
  it { should validate_presence_of :email }
  it { should validate_presence_of :city }
  it { should validate_presence_of :country_code }
  it { should validate_uniqueness_of :email }

  let(:user) { FactoryGirl.build(:user) }

  describe "#verify_email!" do
    it "marks email as verified" do
      user.verify_email!
      user.email_verified?.should be_true
    end
  end

  describe "#email_verification_token" do
    context "on create" do
      it "should generate an email verification token" do
        user.save
        user.email_verification_token.should_not be_nil
      end
    end

    context "on update" do
      it "should not change the email verification token" do
        user.save
        token = user.email_verification_token
        user.update_attributes(:city => "Miami")
        user.email_verification_token.should == token
      end
    end
  end
end

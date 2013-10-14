require 'spec_helper'

describe User do
  it { should validate_presence_of :email }
  it { should validate_presence_of :city }
  it { should validate_presence_of :country_code }
  it { should validate_uniqueness_of :email }

  let(:user) { build(:user) }
  let(:nid)  { successful_response[:body]["national_id"] }

  describe '.find_verified' do
    it 'should not return user with unverified email' do
      user.save
      User.find_verified(user.email).should be_nil
    end

    it 'should return user with verified email' do
      user = create(:verified_user)
      User.find_verified(user.email).should eq user
    end
  end

  describe "#verify_email!" do
    it "marks email as verified" do
      user.verify_email!
      user.email_verified?.should be_true
    end
  end

  describe "#nid_lookup_count" do
    it "should default to 0" do
      user.nid_lookup_count.should eq 0
    end
  end

  describe "#increment_nid_lookup_count!" do
    it "should increment nid_lookup_count by 1" do
      user.increment_nid_lookup_count!
      user.nid_lookup_count.should eq 1
    end
  end

  describe '#national_id_set?' do
    it 'should be false for new users' do
      user.national_id_set?.should be_false
    end

    it 'should be true if national id is saved' do
      user.national_id = nid
      user.save
      user.national_id_set?.should be_true
    end
  end

  describe '#registration_complete?' do
    it 'should be false for new users' do
      user.registration_complete?.should be_false
    end

    it 'should be true after voting location, constituency, and nid is set' do
      user.national_id = nid
      user.constituency_id = 1
      user.voting_location_id = 1
      user.save
      user.registration_complete?.should be_true
    end

    it 'should not be true if only nid is set' do
      user.national_id = nid
      user.save
      user.registration_complete?.should be_false
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

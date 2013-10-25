require 'spec_helper'

describe User do
  it { should validate_presence_of :email }
  it { should validate_presence_of :city }
  it { should validate_presence_of :country_code }
  it { should validate_uniqueness_of :email }
  it { should validate_uniqueness_of :national_id }

  let(:user) { build(:user) }
  let(:nid)  { successful_response[:body]["national_id"] }

  describe "validations" do
    describe "#national_id should scope uniquness by #active" do
      describe "should allow only one active user per national id" do
        it "should save a user if no other active users have the same nid" do
          first_user = create(:user_with_nid)
          second_user = create(:user_with_nid)
          second_user.new_record?.should be_false
        end

        it "should not save a user if another active user has the same nid" do
          first_user = create(:user_with_nid)
          expect {
            second_user = create(:user_with_nid, :national_id => first_user.national_id)

          }.to raise_error ActiveRecord::RecordInvalid
        end
      end

      it "should allow multiple inactive users per national id" do
        first_user = create(:user_with_nid, :active => false)
        second_user = create(:user_with_nid, :active => false, :national_id => first_user.national_id)
        second_user.new_record?.should be_false
      end

      it "should allow one active user and one inactive user per national id" do
        first_user = create(:user_with_nid, :active => false)
        second_user = create(:user_with_nid, :national_id => first_user.national_id)
        second_user.new_record?.should be_false
      end
    end
  end

  context "when password is changed" do
    before do
      user.save
      user.regenerate_password_reset_token!
      user.password_reset_token.should_not be_nil
    end

    it "should clear password reset token" do

      user.password = "newpassword"
      user.password_confirmation = "newpassword"
      user.save

      user.password_reset_token.should be_nil
    end

    it "should only clear password reset token if password is saved" do
      user.password = "pass"
      user.password_confirmation = "pass"
      user.save

      user.password_reset_token.should_not be_nil
    end
  end

  context "when user registration is updated" do
    let!(:user) { create(:registered_user) }
    before { user.validate_registration! }

    context "when constituency is changed" do
      let!(:constituency) { create(:constituency) }

      it "should increment registration submission count" do
        user.update_attributes({:constituency_id => constituency.id, :voting_location_id => user.voting_location_id}, :without_protection => true)
        user.registration_submission_count.should eq 1
      end
    end

    context "when neither constituency nor voting location is changed" do
      it "should not increment registration submission count" do
        user.update_attributes({:constituency_id => user.constituency_id, :voting_location_id => user.voting_location_id}, :without_protection => true)
        user.registration_submission_count.should eq 0
      end
    end
  end

  describe "deactivate!" do
    let(:user) { create(:verified_user) }

    it "should deactivate user" do
      user.deactivate!
      user.reload.active?.should be_false
    end
  end

  describe "reactivate!" do
    let(:user) { create(:verified_user, :active => false) }

    it "should reactivate user" do
      user.reactivate!
      user.reload.active?.should be_true
    end
  end

  describe "claim_nid!" do
    let!(:old_user) { create(:user_with_nid, :national_id => nid) }
    let!(:new_user) { create(:verified_user) }

    it "should deactive existing user with same nid" do
      User.any_instance.stub(:update_attributes!)
      User.any_instance.should_receive(:deactivate!).once
      new_user.claim_nid!(successful_response[:body])
    end

    it "should use a database tranaction" do
      User.any_instance.stub(:update_attributes!).and_raise(ArgumentError)
      new_user.claim_nid!(successful_response[:body])
      old_user.reload.active?.should be_true
    end

    it "should save user successfully with nid" do
      new_user.claim_nid!(successful_response[:body])
      new_user.national_id.should == nid
      new_user.reload.national_id.should == nid
    end
  end

  describe ".swap_nids!" do
    let!(:active_user) { create(:user_with_nid, :national_id => nid) }
    let!(:inactive_user) { create(:user_with_nid, :national_id => nid, :active => false) }

    it "should deactivate active user" do
      active_user.should_receive(:deactivate!)
      User.swap_nids!(active_user, inactive_user)
    end

    it "should reactive deactivated user" do
      inactive_user.should_receive(:reactivate!)
      User.swap_nids!(active_user, inactive_user)
    end
  end

  describe "#suspend!" do
    let(:user) { create(:user) }

    it "should set suspended at to current datetime" do
      frozen_time = Time.zone.now
      Time.stub(:now => frozen_time)

      user.suspend!
      user.reload.suspended_at.to_i.should eq frozen_time.to_i
    end

    it "should reset nid_lookup_count" do
      user.update_attribute(:nid_lookup_count, 5)
      user.suspend!
      user.reload.nid_lookup_count.should eq 0
    end

    it "should return true" do
      user.suspend!.should be_true
    end
  end

  describe '#suspended?' do
    it "should be true if suspended_at is within 4 hours" do
      user.stub(:suspended_at => Time.now-2.hours)
      user.suspended?.should be_true
    end

    it "should be false if suspended_at is nil" do
      user.stub(:suspended_at => nil)
      user.suspended?.should be_false
    end

    it "should be false if suspended_at is more than 4 hours past" do
      user.stub(:suspended_at => Time.now-5.hours)
      user.suspended?.should be_false
    end
  end

  describe '#regenerate_password_reset_token!' do
    let(:user) { create(:verified_user) }

    it "should save a random token" do
      expect {
        user.regenerate_password_reset_token!
      }.to change(user.reload, :password_reset_token)
    end
  end

  describe "#password_too_short?" do
    it "should be true if password is less than 6 characters" do
      user.password = "foo"
      user.password_confirmation = "foo"
      user.save
      user.password_too_short?.should be_true
    end

    it "should be false if password is at least 6 characters" do
      user.save
      user.password_too_short?.should be_false
    end
  end

  describe '#missing_required_signup_fields?' do
    it "should be false if required fields are present" do
      user.save
      user.missing_required_signup_fields?.should be_false
    end

    it "should be true if required fields are blank" do
      user.city = ""
      user.save
      user.missing_required_signup_fields?.should be_true
    end

    it "should be true if password is blank for new user" do
      user = build(:user_with_blank_password)
      user.save
      user.missing_required_signup_fields?.should be_true
    end
  end

  describe '#nonunique_email?' do
    it "should be true if nonunique email" do
      user.save
      another_user = build(:user)
      another_user.email = user.email
      another_user.save
      another_user.nonunique_email?.should be_true
    end

    it "should be false if unique email" do
      user.save
      another_user = build(:user)
      another_user.save
      another_user.nonunique_email?.should be_false
    end
  end

  describe '#invalid_email?' do
    it "should be true if invalid email address format" do
      user.email = "example@com"
      user.save
      user.invalid_email?.should be_true
    end

    it "should be false if valid email address format" do
      user.email = "example@gmail.com"
      user.save
      user.invalid_email?.should be_false
    end
  end

  describe '#nonmatching_password_confirmation?' do
    it "should be true if passwords dont match" do
      user.password_confirmation = "hello"
      user.save
      user.nonmatching_password_confirmation?.should be_true
    end
  end

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

  describe "#registration_changes_allowed" do
    it "should allow 3 submissions" do
      user.registration_changes_allowed.should eq 3
    end

    it "should subtract submission count to calculate value" do
      User.any_instance.stub(:registration_submission_count => 2)
      user.registration_changes_allowed.should eq 1
    end

    it "should not be negative" do
      User.any_instance.stub(:registration_submission_count => 5)
      user.registration_changes_allowed.should eq 0
    end
  end

  describe "#can_modify_registration?" do
    it "should be true if registration_changes_allowed >= 0" do
      User.any_instance.stub(:registration_changes_allowed => 2)
      user.can_modify_registration?.should be_true
    end

    it "should be false if registration_changes_allowed == 0" do
      User.any_instance.stub(:registration_changes_allowed => 0)
      user.can_modify_registration?.should be_false
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

  describe "#validate_registration!" do
    it "sets validate_registration to true" do
      user.validate_registration!
      user.validate_registration.should be_true
    end
  end

  describe "conditional registration validation" do
    context "when registration validation is enabled" do
      before { user.validate_registration! }

      it "user should be invalid" do
        user.valid?.should be_false
      end

      it "user should be valid if constituency and voting location are set" do
        user.voting_location_id = 1
        user.constituency_id = 1
        user.valid?.should be_true
      end
    end
  end

  describe "#full_name" do
    it "should combine family name, grandfather name, father name, and first name" do
      User.any_instance.stub(:family_name => "Noda",
                             :grandfather_name => "Stanley",
                             :father_name => "Corey",
                             :first_name => "Abi")
      user.full_name.should eq "Abi Corey Stanley Noda"
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

require "spec_helper"

describe ApplicationHelper, 'display_password_confirmation_error?' do
  before do
    @user = create(:verified_user)
    @user.stub(:nonmatching_password_confirmation? => true)
    @user.errors[:password] = ["1 error"]
  end

  it 'returns true if user password confirmation is ' do
    helper.display_password_confirmation_error?.should be_true
  end

  it 'returns false if user password has multiple errors' do
    @user.errors[:password] << "another error"
    helper.display_password_confirmation_error?.should be_false
  end
end

class SignupsController < ApplicationController
  before_filter :ensure_voter_registration_open

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])

    if @user.save_with_captcha
      I18nMailer.deliver Mailer, :email_verification, @user
      current_user_session.destroy
      redirect_to confirm_path
    else
      render :new
    end
  end

  private

  def ensure_voter_registration_open
    redirect_to closed_path and return if voter_registration_closed?
  end
end

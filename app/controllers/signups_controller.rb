class SignupsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])

    if @user.save_with_captcha
      Mailer.delay.email_verification(@user)
      redirect_to confirm_path
    else
      render :new
    end
  end
end

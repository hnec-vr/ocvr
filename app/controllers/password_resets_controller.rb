class PasswordResetsController < ApplicationController
  before_filter :require_token, :only => [:edit, :update]

  def new
  end

  def create
    if user = User.find_by_email(params[:email])
      user.regenerate_password_reset_token!
      I18nMailer.deliver Mailer, :reset_password, user
      redirect_to sent_password_resets_path
    else
      render :new
    end
  end

  def sent
  end

  def edit
  end

  def update
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    @user.validate_password = true

    if @user.save
      redirect_to login_path
    else
      render :edit
    end
  end

  private

  def require_token
    redirect_to root_path unless @user = User.find_by_password_reset_token(params[:id])
  end
end

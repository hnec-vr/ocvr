class SignupsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])

    if @user.save_with_captcha
      redirect_to confirm_path
    else
      render :new
    end
  end
end

class UserSessionsController < ApplicationController
  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])

    if @user_session.save
      redirect_to account_path
    else
      @failed_login = true
      render :new
    end
  end
end

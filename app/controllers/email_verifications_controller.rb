class EmailVerificationsController < ApplicationController
  def verify
    user = User.find_by_email_verification_token(params[:token])

    redirect_to root_path and return unless user

    user.verify_email!

    redirect_to login_path, :notice => t('email_verification.success_flash')
  end
end

class Admin::UsersController < Admin::BaseController
  def activate
    user = User.find(params[:id])
    user.activate!
    I18nMailer.deliver Mailer, :nid_approval, user

    redirect_to admin_nid_reviews_path
  end

  def deactivate
    user = User.find(params[:id])
    user.deactivate!
    I18nMailer.deliver Mailer, :account_deactivated, user

    redirect_to admin_nid_reviews_path
  end
end

class ApplicationController < ActionController::Base
  include SimpleCaptcha::ControllerHelpers

  protect_from_forgery

  helper_method :current_user, :simple_captcha_valid?
  before_filter :no_layout_if_xhr, :set_locale

  protected

  def current_user
    @current_user ||= current_user_session && current_user_session.record
  end

  def require_login
    redirect_to login_path and return unless current_user
  end

  private

  def current_user_session
    @current_user_session ||= UserSession.find
  end

  def no_layout_if_xhr
    false if request.xhr?
  end

  def set_locale
    I18n.locale = session[:locale] || I18n.default_locale
  end
end

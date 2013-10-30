class ApplicationController < ActionController::Base
  include SimpleCaptcha::ControllerHelpers

  protect_from_forgery

  helper_method :current_user, :simple_captcha_valid?, :voter_registration_closed?
  before_filter :no_www, :no_layout_if_xhr, :capture_locale, :set_locale

  protected

  def ensure_not_suspended
    redirect_to suspended_path and return if current_user.suspended?
  end

  def current_user
    @current_user ||= current_user_session && current_user_session.record
  end

  def require_login
    redirect_to login_path and return unless current_user
  end

  def voter_registration_closed?
    Date.today > ::SETTINGS[:voter_registration_deadline]
  end

  def current_user_session
    @current_user_session ||= UserSession.find
  end

  private

  def no_www
    if /^www/.match(request.host)
      redirect_to (config.force_ssl ? 'https://' : 'http://') + ::SETTINGS[:default_host] + request.fullpath
      flash.keep
    end
  end

  def capture_locale
    if params[:locale] && %w(en ar).include?(params[:locale])
      session[:locale] = params[:locale]
    end
  end

  def no_layout_if_xhr
    false if request.xhr?
  end

  def set_locale
    I18n.locale = session[:locale] || I18n.default_locale
  end
end

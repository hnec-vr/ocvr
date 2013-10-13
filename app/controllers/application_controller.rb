class ApplicationController < ActionController::Base
  include SimpleCaptcha::ControllerHelpers

  protect_from_forgery

  before_filter :no_layout_if_xhr, :set_locale

  private

  def no_layout_if_xhr
    false if request.xhr?
  end

  def set_locale
    I18n.locale = session[:locale] || I18n.default_locale
  end
end

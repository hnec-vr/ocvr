class Admin::BaseController < ApplicationController
  http_basic_authenticate_with name: ENV["ADMIN_USERNAME"], password: ENV["ADMIN_PASSWORD"]
  layout "admin"

  before_filter :set_locale_to_en

  def set_locale_to_en
    I18n.locale = :en
  end
end

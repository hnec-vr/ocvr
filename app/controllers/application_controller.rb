class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :no_layout_if_xhr

  private

  def no_layout_if_xhr
    false if request.xhr?
  end
end

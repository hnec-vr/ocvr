class AccountsController < ApplicationController
  before_filter :require_login, :ensure_not_suspended

  def show
  end
end

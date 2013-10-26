class UserSession < Authlogic::Session::Base
  find_by_login_method :find_active_and_verified
  logout_on_timeout true
end

class UserSession < Authlogic::Session::Base
  find_by_login_method :find_verified
end

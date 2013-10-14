module Controllers
  module AuthenticationHelpers
    def sign_in(user)
      u = UserSession.create(user)
    end

    def sign_out
      us = UserSession.find
      us.destroy
    end

    def logged_in?
      current_user_session = UserSession.find
      return current_user_session.record if current_user_session
      return false
    end
  end
end

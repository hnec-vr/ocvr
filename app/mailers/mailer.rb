class Mailer < ActionMailer::Base
  default from:     "info@domain.ly",
          reply_to: "info@domain.ly"

  def email_verification(user)
    @user = user

    mail :to => user.email,
         :subject => t("emails.email_verification.subject")
  end

  def nid_approval(nid_review)
    mail :to => nid_review.user.email,
         :subject => "Your account has been verified"
  end

  def nid_denial(nid_review)
    mail :to => nid_review.user.email,
         :subject => "We could not verify your account"
  end

  def reset_password(user)
    @token = user.password_reset_token

    mail :to => user.email,
         :subject => "Reset your password"
  end
end

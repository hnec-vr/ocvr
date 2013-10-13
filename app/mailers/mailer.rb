class Mailer < ActionMailer::Base
  default from:     "info@domain.ly",
          reply_to: "info@domain.ly"

  def email_verification(user)
    @user = user

    mail :to => user.email,
         :subject => t("emails.email_verification.subject")
  end
end

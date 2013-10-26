class Mailer < ActionMailer::Base
  default from:     "no-reply@voteabroad.ly"

  def email_verification(user)
    @user = user

    mail :to => user.email,
         :subject => t("email_subjects.email_verification")
  end

  def nid_approval(user)
    mail :to => user.email,
         :subject => t('email_subjects.nid_approval')
  end

  def nid_denial(user)
    mail :to => user.email,
         :subject => t('email_subjects.nid_denial')
  end

  def account_deactivated(user)
    mail :to => user.email,
         :subject => t('email_subjects.account_deactivated')
  end

  def reset_password(user)
    @token = user.password_reset_token

    mail :to => user.email,
         :subject => t('email_subjects.reset_password')
  end
end

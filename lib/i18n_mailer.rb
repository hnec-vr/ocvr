class I18nMailer
  def self.deliver(mailer, method, *args)
    delay.set_locale_and_deliver(I18n.locale, mailer, method, args)
  end

  private

  def self.set_locale_and_deliver(locale, mailer, mailer_method, args)
    previous_locale = I18n.locale
    I18n.locale = locale
    mailer.send(mailer_method, *args).deliver
  ensure
    I18n.locale = previous_locale
  end
end

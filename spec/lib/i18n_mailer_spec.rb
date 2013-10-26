require 'spec_helper'

describe I18nMailer do
  before { Delayed::Worker.delay_jobs = true }
  after { Delayed::Worker.delay_jobs = false }

  it 'sets the locale, then delivers the message' do
    I18n.locale = :es
    I18nMailer.deliver LocaleMailer, :my_message
    ActionMailer::Base.deliveries.length.should == 0

    I18n.locale = :en
    Delayed::Worker.new.work_off
    ActionMailer::Base.deliveries.length.should == 1
    ActionMailer::Base.deliveries.first.body.should == "locale was es when this message was sent"

    I18n.locale.should == :en
  end

  class LocaleMailer < ActionMailer::Base
    def my_message
      mail(
          body: "locale was #{I18n.locale} when this message was sent",
          from: "a@example.com",
          to: "b@example.com"
      )
    end
  end
end

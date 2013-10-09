class User < ActiveRecord::Base
  acts_as_authentic
  apply_simple_captcha :add_to_base => true

  validates_presence_of :email, :country_code, :city
  validates_uniqueness_of :email

  before_validation :generate_email_verification_token, :on => :create

  private

  def generate_email_verification_token
    self.email_verification_token = SecureRandom::hex(32)
  end
end

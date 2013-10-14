class User < ActiveRecord::Base
  acts_as_authentic
  apply_simple_captcha :add_to_base => true

  validates_presence_of :email, :country_code, :city
  validates_uniqueness_of :email

  before_validation :generate_email_verification_token, :on => :create

  scope :verified, where(:email_verified => true)

  def verify_email!
    update_attribute(:email_verified, true)
  end

  def increment_nid_lookup_count!
    increment!(:nid_lookup_count)
  end

  def national_id_set?
    national_id.present?
  end

  def registration_complete?
    national_id && constituency_id && voting_location_id
  end

  def self.find_verified(email)
    self.verified.find_by_email(email)
  end

  private

  def generate_email_verification_token
    self.email_verification_token = SecureRandom::hex(32)
  end
end

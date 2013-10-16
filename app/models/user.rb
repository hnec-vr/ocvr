require 'valid_email'

class User < ActiveRecord::Base
  acts_as_authentic
  apply_simple_captcha :add_to_base => true
  attr_accessor :validate_registration

  belongs_to :constituency
  belongs_to :voting_location

  validates_presence_of :country_code, :city
  validates :email, :presence => true, :uniqueness => true, :email => true
  validates_presence_of :password, :password_confirmation, :on => :create
  validates_presence_of :constituency_id, :voting_location_id, :if => :validate_registration

  before_validation :generate_email_verification_token, :on => :create

  scope :verified, where(:email_verified => true)

  def validate_registration!
    @validate_registration = true
  end

  def full_name
    [family_name, grandfather_name, father_name, first_name].join(" ")
  end

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

  def registration_changes_allowed
    return 0 if registration_submission_count >= 3
    return 3 - registration_submission_count
  end

  def can_modify_registration?
    registration_changes_allowed > 0
  end

  def self.find_verified(email)
    self.verified.find_by_email(email)
  end

  def missing_required_signup_fields?
    errors.messages.flatten.flatten.include?("can't be blank")
  end

  def nonunique_email?
    self.errors[:email].include?("has already been taken")
  end

  def invalid_email?
    self.errors[:email].include?("should look like an email address.")
  end

  def nonmatching_password_confirmation?
    self.errors[:password].include?("doesn't match confirmation")
  end

  private

  def generate_email_verification_token
    self.email_verification_token = SecureRandom::hex(32)
  end
end

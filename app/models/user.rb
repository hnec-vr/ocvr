require 'valid_email'

class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.merge_validates_length_of_password_confirmation_field_options :minimum => 6
    c.merge_validates_length_of_password_field_options :minimum => 6
    c.logged_in_timeout = 60.minutes
  end

  apply_simple_captcha :add_to_base => true
  attr_accessor :validate_registration, :validate_password
  attr_accessible :email, :password, :password_confirmation,
                  :country_code, :city, :captcha, :captcha_key

  belongs_to :constituency
  belongs_to :voting_location

  validates_presence_of :country_code, :city
  validates :email, :presence => true, :uniqueness => true, :email => true
  validates_presence_of :password, :password_confirmation, :if => :should_validate_password?
  validates_presence_of :constituency_id, :voting_location_id, :if => :validate_registration

  before_validation :generate_email_verification_token, :on => :create
  before_update :clear_password_reset_token, :if => :password_changed?
  before_update :increment_registration_submission_count,
    :if => Proc.new {|user| user.validate_registration && user.constituency_id_changed? or user.voting_location_id_changed? }

  scope :verified, where(:email_verified => true)
  scope :active, where(:active => true)

  def deactivate!
    update_attribute(:active, false)
  end

  def activate!
    update_attribute(:active, true)
  end

  def suspend!
    self.suspended_at = Time.now
    self.nid_lookup_count = 0
    save(:validate => false)
  end

  def suspended?
    suspended_at && suspended_at > Time.now-4.hours
  end

  def validate_registration!
    @validate_registration = true
  end

  def full_name
    [first_name, father_name, grandfather_name, family_name].join(" ")
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

  def self.find_active_and_verified(email)
    self.active.verified.find_by_email(email)
  end

  def password_too_short?
    self.errors[:password].include?("is too short (minimum is 6 characters)")
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

  def regenerate_password_reset_token!
    update_attribute(:password_reset_token, SecureRandom::hex(32))
  end

  private

  def clear_password_reset_token
    self.password_reset_token = nil
  end

  def should_validate_password?
    @validate_password || new_record?
  end

  def generate_email_verification_token
    self.email_verification_token = SecureRandom::hex(32)
  end

  def increment_registration_submission_count
    increment(:registration_submission_count)
  end
end

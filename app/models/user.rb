class User < ActiveRecord::Base
  acts_as_authentic
  apply_simple_captcha :add_to_base => true
  attr_accessor :validate_registration

  belongs_to :constituency
  belongs_to :voting_location

  validates_presence_of :email, :country_code, :city
  validates_uniqueness_of :email
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

  private

  def generate_email_verification_token
    self.email_verification_token = SecureRandom::hex(32)
  end
end

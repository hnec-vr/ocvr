class NidReview < ActiveRecord::Base
  belongs_to :user
  belongs_to :original_user, :class_name => "User"

  serialize :nid_data

  validates_presence_of :user_id, :original_user_id, :registry_number, :mother_name, :nid_data

  before_validation :set_original_user, :on => :create

  def user
    User.unscoped { super }
  end

  def original_user
    User.unscoped { super }
  end

  def processed?
    !approved.nil?
  end

  def deny!
    update_attribute :approved, false
  end

  def approve!
    transaction do
      begin
        update_attribute :approved, true
        user.claim_nid!(nid_data)
      rescue
        raise ActiveRecord::Rollback
      end
    end
  end

  def national_id
    nid_data.try(:[], "national_id")
  end

  private

  def set_original_user
    self.original_user = User.find_by_national_id(national_id)
  end
end

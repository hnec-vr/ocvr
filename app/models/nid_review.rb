class NidReview < ActiveRecord::Base
  belongs_to :user

  serialize :nid_data

  validates_presence_of :user_id, :registry_number, :mother_name, :nid_data

  def user
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
end

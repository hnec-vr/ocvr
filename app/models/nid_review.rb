class NidReview < ActiveRecord::Base
  belongs_to :user

  serialize :nid_data

  validates_presence_of :user_id, :national_id, :registry_number, :mother_name, :nid_data

  default_scope :order => "verdict NULLS FIRST, created_at DESC"

  before_validation :set_national_id, :on => :create

  def user
    User.unscoped { super }
  end

  def processed?
    !!verdict
  end

  def deny!
    update_attribute :verdict, "denied"
  end

  def approve!
    transaction do
      begin
        update_attribute :verdict, "approved"
        user.update_attributes nid_data, :without_protection => true
      rescue
        raise ActiveRecord::Rollback
      end
    end
  end

  private

  def set_national_id
    self.national_id = nid_data.try(:[], "national_id")
  end
end

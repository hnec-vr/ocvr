class CreateNidReviews < ActiveRecord::Migration
  def change
    create_table :nid_reviews do |t|
      t.integer  :user_id
      t.integer  :registry_number
      t.string   :mother_name
      t.text     :nid_data
      t.boolean  :approved
      t.datetime :created_at
    end
  end
end

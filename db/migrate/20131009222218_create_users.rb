class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string   :email
      t.string   :city
      t.string   :country_code
      t.column   :national_id, :bigint
      t.date     :birth_date
      t.string   :family_name
      t.string   :father_name
      t.string   :first_name
      t.string   :grandfather_name
      t.string   :mother_name
      t.string   :gender
      t.integer  :registry_number
      t.integer  :voting_location_id
      t.integer  :constituency_id
      t.string   :password_reset_token
      t.string   :email_verification_token
      t.boolean  :email_verified, :default => false
      t.integer  :nid_lookup_count, :default => 0
      t.integer  :registration_submission_count, :default => 0
      t.datetime :suspended_at
      t.boolean  :active, :default => true
      t.string   :password_salt
      t.string   :password_hash
      t.string   :persistence_token
      t.string   :last_login_ip
      t.string   :current_login_ip
      t.datetime :last_request_at
      t.datetime :created_at
    end

    add_index :users, :email, :unique => true
    add_index :users, :active
    add_index :users, :national_id
    add_index :users, :email_verification_token, :unique => true
  end
end

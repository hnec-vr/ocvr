# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131014172104) do

  create_table "constituencies", :force => true do |t|
    t.string "name"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0, :null => false
    t.integer  "attempts",   :default => 0, :null => false
    t.text     "handler",                   :null => false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "simple_captcha_data", :force => true do |t|
    t.string   "key",        :limit => 40
    t.string   "value",      :limit => 6
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "simple_captcha_data", ["key"], :name => "idx_key"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "city"
    t.string   "country_code"
    t.integer  "national_id",                   :limit => 8
    t.date     "birth_date"
    t.string   "family_name"
    t.string   "father_name"
    t.string   "first_name"
    t.string   "grandfather_name"
    t.string   "mother_name"
    t.string   "gender"
    t.integer  "voting_location_id"
    t.integer  "constituency_id"
    t.string   "password_reset_token"
    t.string   "email_verification_token"
    t.boolean  "email_verified",                             :default => false
    t.integer  "nid_lookup_count",                           :default => 0
    t.integer  "registration_submission_count",              :default => 0
    t.string   "password_salt"
    t.string   "password_hash"
    t.string   "persistence_token"
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.datetime "last_request_at"
    t.datetime "created_at"
  end

  create_table "voting_locations", :force => true do |t|
    t.string "en"
    t.string "ar"
  end

end

class CreateConstituency < ActiveRecord::Migration
  def change
    create_table :constituencies do |t|
      t.string   :name
      t.string   :en_translation
      t.string   :main_district
    end
  end
end

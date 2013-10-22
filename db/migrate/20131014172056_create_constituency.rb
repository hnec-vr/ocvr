class CreateConstituency < ActiveRecord::Migration
  def change
    create_table :constituencies do |t|
      t.string   :name
      t.string   :en_translation
    end
  end
end

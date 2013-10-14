class CreateConstituency < ActiveRecord::Migration
  def change
    create_table :constituencies do |t|
      t.string   :name
    end
  end
end

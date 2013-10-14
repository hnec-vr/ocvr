class CreateVotingLocation < ActiveRecord::Migration
  def change
    create_table :voting_locations do |t|
      t.string   :en
      t.string   :ar
    end
  end
end

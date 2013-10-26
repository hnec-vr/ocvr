require "csv"

assets_path = Rails.root.join('lib', 'assets')

CSV.foreach assets_path.join("voting_locations.csv") do |row|
  VotingLocation.create!(:en => row[0], :ar => row[1])
end

CSV.foreach assets_path.join("constituencies.csv") do |row|
  Constituency.create!(:name => row[0], :en_translation => row[1], :main_district => row[2])
end

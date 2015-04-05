# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
require 'yaml'
require 'csv'

# -- Spree
unless Spree::Country.find_by_name(ENV['DEFAULT_COUNTRY'])
  puts "[db:seed] Seeding Spree"
  Spree::Core::Engine.load_seed if defined?(Spree::Core)
  Spree::Auth::Engine.load_seed if defined?(Spree::Auth)
end

country = Spree::Country.find_by_name(ENV['DEFAULT_COUNTRY'])
puts "Country is #{country.to_s}"
puts "[db:seed] loading states yaml"
states = YAML::load_file "db/default/spree/states.yml"
puts "States: #{states.to_s}"
states_ids = {}
puts "[db:seed] loading suburbs csv"
suburbs_file = File.join ['db', 'suburbs.csv']

# -- Seeding States
  puts "[db:seed] Seeding states for " + country.name

states.each do |id,state|
  puts id
  puts "State: " + state.to_s
  unless Spree::State.find_by_name(state['name'])
    Spree::State.create!({"name"=>state['name'], "abbr"=>state['abbr'], :country=>country}, without_protection: true)
  end
  puts "set id"
  states_ids[state['abbr']] = Spree::State.where(abbr: state['abbr']).where(country_id: country.id).first.id
end

# -- Seeding suburbs

# Build sql insert statement.
name = ''
statement = "INSERT INTO suburbs (postcode,name,state_id,latitude,longitude) VALUES\n"

puts "State ids:" + states_ids.to_s

# Format datatfrom suburbs csv
CSV.foreach(suburbs_file, {headers: true, header_converters: :symbol}) do |row|
  postcode = row[:postcode]
  name = row[:name]
  lat = row[:latitude]
  long = row[:longitude]
  state_id = states_ids[row[:state]]
  statement += "(#{postcode},$$#{name}$$,#{state_id},#{lat},#{long}),"
end
statement[-1] = ';'

puts statement

unless Suburb.find_by_name(name)
  puts "[db:seed] Seeding suburbs for country.name"
  connection = ActiveRecord::Base.connection()
  connection.execute(statement)
else
  puts '[db:seed] Suburbs seeded already!'
end

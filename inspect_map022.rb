# Quick script to inspect Map022 events
require 'zlib'

# Load function
def load_data(filename)
  File.open(filename, "rb") do |file|
    Marshal.load(file)
  end
end

# Load the map
map_data = load_data("Data/Map022.rxdata")

puts "Map 022 Inspection"
puts "=" * 50
puts "Tileset ID: #{map_data.tileset_id}"
puts "Number of events: #{map_data.events.length}"
puts ""

# List all events
map_data.events.each do |event_id, event|
  next if event.nil?
  puts "\nEvent #{event_id}: #{event.name} at (#{event.x}, #{event.y})"
  puts "  Pages: #{event.pages.length}"
  
  event.pages.each_with_index do |page, page_idx|
    puts "  Page #{page_idx}:"
    puts "    Graphic: #{page.graphic.character_name}"
    puts "    Direction: #{page.graphic.direction}"
    puts "    Pattern: #{page.graphic.pattern}"
    puts "    Tile ID: #{page.graphic.tile_id}"
    puts "    Step Anime: #{page.step_anime}"
    puts "    Walk Anime: #{page.walk_anime}"
    puts "    Direction Fix: #{page.direction_fix}"
    puts "    Commands: #{page.list.length}"
  end
end

puts "\n" + "=" * 50
puts "Tileset ID 0 means NO TILESET (black map)"

# Simple script to create Map022 from Map002 template
# This creates an empty map with the tileset from Map002

def load_data(filename)
  File.open(filename, "rb") { |f| Marshal.load(f) }
end

# Load Map002 as template
map002 = load_data("Data/Map002.rxdata")

# Clear all events
map002.events.clear

puts "Creating Map022 from Map002 template..."
puts "  Tileset ID: #{map002.tileset_id}"
puts "  Width: #{map002.width}"
puts "  Height: #{map002.height}"
puts "  Events cleared: #{map002.events.length}"

# Save as Map022
File.open("Data/Map022.rxdata", "wb") { |f| Marshal.dump(map002, f) }

puts "✓ Map022 created successfully!"
puts "Now start the game to import events."

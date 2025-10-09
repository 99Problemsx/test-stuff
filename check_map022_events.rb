# Check Map022 events in detail
# Run this from the game's context (paste into Scripts/Main)

map = load_data("Data/Map022.rxdata")

puts "=" * 60
puts "Map022 Analysis"
puts "=" * 60
puts "Tileset ID: #{map.tileset_id}"
puts "Width: #{map.width} x Height: #{map.height}"
puts "Total Events: #{map.events.length}"
puts ""

if map.events.empty?
  puts "WARNING: No events found!"
else
  puts "Event List:"
  puts "-" * 60
  
  map.events.each do |id, event|
    next if event.nil?
    
    graphic = event.pages[0].graphic.character_name rescue "NONE"
    commands = event.pages[0].list.length rescue 0
    
    # Check if coordinates are within map bounds
    valid = (event.x >= 0 && event.x < map.width && event.y >= 0 && event.y < map.height)
    status = valid ? "✓" : "✗ OUT OF BOUNDS!"
    
    puts sprintf("%s [%03d] %-25s at (%2d,%2d) | Graphic: %-20s | Commands: %d", 
                 status, id, event.name, event.x, event.y, graphic, commands)
  end
end

puts "=" * 60

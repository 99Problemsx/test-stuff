# Clear imported events from Map 003
# This removes all events that were added by the Event Importer

map_file = "Data/Map003.rxdata"

if File.exist?(map_file)
  map = load_data(map_file)
  
  # Count events before
  before_count = map.events.length
  puts "Events before: #{before_count}"
  
  # List all event IDs and names
  puts "\nAll events:"
  map.events.keys.sort.each do |event_id|
    event = map.events[event_id]
    puts "  #{event_id}: #{event.name}"
  end
  
  # The original map has events up to ID 22 (approximately)
  # Events with ID >= 23 are likely imported
  original_max_id = 22
  
  puts "\nDeleting events with ID > #{original_max_id}..."
  
  # Remove all events with ID > original_max_id
  deleted_events = []
  map.events.keys.each do |event_id|
    if event_id > original_max_id
      event = map.events[event_id]
      deleted_events << "#{event_id}: #{event.name}"
      map.events.delete(event_id)
    end
  end
  
  # Count events after
  after_count = map.events.length
  deleted_count = before_count - after_count
  
  puts "\nDeleted #{deleted_count} events:"
  deleted_events.each { |e| puts "  - #{e}" }
  
  # Save the map
  File.open(map_file, "wb") { |f| Marshal.dump(map, f) }
  
  puts "\nEvents remaining: #{after_count}"
  puts "Map003 saved successfully!"
else
  puts "Map003.rxdata not found!"
end

puts "\nDone! You can now restart the game to re-import events."

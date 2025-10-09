# Quick script to reimport events from text files
# Run this in the Debug console (F12) or as a script

puts "=== REIMPORTING EVENTS ==="
count = EventImporter.import_all_events
puts "=== REIMPORT COMPLETE: #{count} events imported ==="
puts "The map will reload now."

# Reload the current map to see the changes
$game_map.setup($game_map.map_id) if $game_map
$scene.spriteset.dispose if $scene && $scene.spriteset
$scene.spriteset = Spriteset_Map.new if $scene

puts "Done! Events updated."

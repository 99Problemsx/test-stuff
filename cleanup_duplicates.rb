# Cleanup duplicate events
# This script removes duplicate events that have the same name and position

require 'zlib'

# Minimal RPG classes
module RPG
  class Map
    attr_accessor :events
  end
  class Event
    attr_accessor :id, :name, :x, :y, :pages
  end
  class Event::Page
    attr_accessor :condition, :graphic, :move_type, :move_speed, :move_frequency
    attr_accessor :move_route, :walk_anime, :step_anime, :direction_fix
    attr_accessor :through, :always_on_top, :trigger, :list
  end
  class Event::Page::Condition
    attr_accessor :switch1_valid, :switch2_valid, :variable_valid, :self_switch_valid
    attr_accessor :switch1_id, :switch2_id, :variable_id, :variable_value, :self_switch_ch
  end
  class Event::Page::Graphic
    attr_accessor :tile_id, :character_name, :character_hue, :direction, :pattern, :opacity, :blend_type
  end
  class EventCommand
    attr_accessor :code, :indent, :parameters
  end
  class MoveRoute
    attr_accessor :repeat, :skippable, :list
  end
  class MoveCommand
    attr_accessor :code, :parameters
  end
  class AudioFile
    attr_accessor :name, :volume, :pitch
  end
end

class Table
  def initialize(*args); end
  def self._load(data); new; end
end

class Tone
  def initialize(*args); end
  def self._load(data); new; end
end

class Color
  def initialize(*args); end
  def self._load(data); new; end
end

# Load Map 003
map_file = "Data/Map003.rxdata"
map = nil

File.open(map_file, "rb") do |f|
  map = Marshal.load(f)
end

puts "=== Scanning for duplicate events ==="
puts "Total events: #{map.events.length}"

# Find duplicates by name+position
seen = {}
duplicates = []

map.events.each do |id, event|
  key = "#{event.name}_#{event.x}_#{event.y}"
  
  if seen[key]
    # This is a duplicate
    duplicates << id
    puts "DUPLICATE: Event #{id} '#{event.name}' at (#{event.x}, #{event.y}) - first seen as ID #{seen[key]}"
  else
    seen[key] = id
  end
end

if duplicates.empty?
  puts "No duplicates found!"
else
  puts "\n=== Removing #{duplicates.length} duplicate event(s) ==="
  
  duplicates.each do |id|
    event = map.events[id]
    puts "Deleting Event #{id}: #{event.name} at (#{event.x}, #{event.y})"
    map.events.delete(id)
  end
  
  # Save the map
  File.open(map_file, "wb") do |f|
    Marshal.dump(map, f)
  end
  
  puts "\n✓ Map saved with duplicates removed!"
  puts "Events remaining: #{map.events.length}"
end

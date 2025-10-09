#!/usr/bin/env ruby
# Debug script to check Map 3 event structure

def load_data(filename)
  File.open(filename, 'rb') do |file|
    Marshal.load(file)
  end
end

# Need to define RPG module structure
module RPG
  class Map
    attr_accessor :events
  end
  
  class Event
    attr_accessor :id, :name, :x, :y, :pages
  end
  
  class Event::Page
    attr_accessor :list
  end
  
  class EventCommand
    attr_accessor :code, :indent, :parameters
  end
end

puts "Loading Map 3..."
map = load_data('Data/Map003.rxdata')

puts "\n=== Checking Quest NPC (Event 40) ==="
event40 = map.events[40]
if event40
  puts "Event Name: #{event40.name}"
  puts "Position: (#{event40.x}, #{event40.y})"
  puts "\nPage 1 Commands:"
  event40.pages[0].list.each_with_index do |cmd, idx|
    puts "  [#{idx}] Code: #{cmd.code}, Indent: #{cmd.indent}, Params: #{cmd.parameters.inspect}"
    if cmd.code == 102
      puts "      -> Show Choices: #{cmd.parameters[0].inspect}"
    elsif cmd.code == 402
      puts "      -> When [Choice]"
    elsif cmd.code == 404
      puts "      -> Branch End"
    end
  end
end

puts "\n=== Checking Pokemon Manager (Event 53) ==="
event53 = map.events[53]
if event53
  puts "Event Name: #{event53.name}"
  puts "Position: (#{event53.x}, #{event53.y})"
  puts "\nPage 1 Commands:"
  event53.pages[0].list.each_with_index do |cmd, idx|
    puts "  [#{idx}] Code: #{cmd.code}, Indent: #{cmd.indent}, Params: #{cmd.parameters.inspect}"
    if cmd.code == 102
      puts "      -> Show Choices: #{cmd.parameters[0].inspect}"
    elsif cmd.code == 402
      puts "      -> When [Choice]"
    elsif cmd.code == 404
      puts "      -> Branch End"
    end
  end
end

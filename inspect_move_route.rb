require 'zlib'

# Load Map 003
map_data = File.binread('Data/Map003.rxdata')
begin
  map = Marshal.load(Zlib::Inflate.inflate(map_data))
rescue Zlib::DataError
  # Not compressed
  map = Marshal.load(map_data)
end

# Find event with "port" in name
port_event = map.events.values.find { |e| e.name =~ /port/i }

if port_event
  puts "Found event: #{port_event.name}"
  
  port_event.pages.each_with_index do |page, page_idx|
    puts "\n=== Page #{page_idx + 1} ==="
    
    page.list.each_with_index do |cmd, cmd_idx|
      if cmd.code == 209  # Set Move Route
        puts "\nFound SET_MOVE_ROUTE at command #{cmd_idx}"
        puts "Command: #{cmd.inspect}"
        puts "\nParameters: #{cmd.parameters.inspect}"
        
        target = cmd.parameters[0]
        move_route = cmd.parameters[1]
        
        puts "\nTarget: #{target}"
        puts "Move Route: #{move_route.inspect}"
        puts "  repeat: #{move_route.repeat}"
        puts "  skippable: #{move_route.skippable}"
        puts "  list length: #{move_route.list.length}"
        
        puts "\n  Commands:"
        move_route.list.each_with_index do |mc, i|
          puts "    [#{i}] code=#{mc.code}, params=#{mc.parameters.inspect}"
        end
      end
    end
  end
else
  puts "No port event found. Available events:"
  map.events.each do |id, event|
    puts "  #{id}: #{event.name}"
  end
end

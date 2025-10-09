require 'zlib'

# Load Map 003
map_data = File.binread('Data/Map003.rxdata')
begin
  map = Marshal.load(Zlib::Inflate.inflate(map_data))
rescue Zlib::DataError
  map = Marshal.load(map_data)
end

# Find Gallery event (ID 48)
gallery = map.events[48]

if gallery
  puts "Gallery Event found!"
  puts "Name: #{gallery.name}"
  puts "Pages: #{gallery.pages.length}"
  
  gallery.pages.each_with_index do |page, page_idx|
    puts "\n=== Page #{page_idx + 1} ==="
    page.list.each_with_index do |cmd, cmd_idx|
      puts "\nCommand #{cmd_idx}: Code #{cmd.code}"
      puts "  Indent: #{cmd.indent}"
      puts "  Parameters: #{cmd.parameters.inspect}"
      
      if cmd.code == 231  # Show Picture
        puts "\n  SHOW PICTURE DETAILS:"
        puts "    [0] pic_num: #{cmd.parameters[0].inspect} (#{cmd.parameters[0].class})"
        puts "    [1] pic_name: #{cmd.parameters[1].inspect} (#{cmd.parameters[1].class})"
        puts "    [2] origin: #{cmd.parameters[2].inspect} (#{cmd.parameters[2].class})"
        puts "    [3] appointment: #{cmd.parameters[3].inspect} (#{cmd.parameters[3].class})"
        puts "    [4] x: #{cmd.parameters[4].inspect} (#{cmd.parameters[4].class})"
        puts "    [5] y: #{cmd.parameters[5].inspect} (#{cmd.parameters[5].class})"
        puts "    [6] zoom_x: #{cmd.parameters[6].inspect} (#{cmd.parameters[6].class})"
        puts "    [7] zoom_y: #{cmd.parameters[7].inspect} (#{cmd.parameters[7].class})"
        puts "    [8] opacity: #{cmd.parameters[8].inspect} (#{cmd.parameters[8].class})"
        puts "    [9] blend: #{cmd.parameters[9].inspect} (#{cmd.parameters[9].class})"
      end
    end
  end
else
  puts "Gallery event (ID 48) not found!"
  puts "Available events:"
  map.events.each do |id, event|
    puts "  #{id}: #{event.name}"
  end
end

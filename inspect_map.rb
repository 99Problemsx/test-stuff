# Quick script to inspect Map002 tileset data
map = Marshal.load(File.binread("Data/Map002.rxdata"))

puts "Map002 Information:"
puts "==================="
puts "Tileset ID: #{map.tileset_id}"
puts "Width: #{map.width}"
puts "Height: #{map.height}"
puts ""

# Sample a few positions to see actual tile IDs
puts "Sampling tiles from Map002:"
(0..4).each do |y|
  (0..4).each do |x|
    l1 = map.data[x, y, 0]
    l2 = map.data[x, y, 1]
    l3 = map.data[x, y, 2]
    if l1 != 0 || l2 != 0 || l3 != 0
      puts "Position (#{x}, #{y}): Layer1=#{l1}, Layer2=#{l2}, Layer3=#{l3}"
    end
  end
end

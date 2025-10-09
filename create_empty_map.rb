# Create an empty Map021 to prevent crashes
map = RPG::Map.new(20, 15)
map.tileset_id = 1
map.events = {}
save_data(map, "Data/Map021.rxdata")
puts "Created empty Map021.rxdata"

#===============================================================================
# RMXP Map Builder - Tile-by-Tile Map Construction
# Version: 1.0.0
# Author: AI Assistant
# Compatible with: Pokemon Essentials v21+
#===============================================================================
# This script allows building maps tile-by-tile from text-based layouts
# Place layout files in EventImporter/ folder with .map extension
#===============================================================================

module MapBuilder
  # Pokemon Essentials Outside tileset tile IDs
  # These are REAL tile IDs from Map 002 analysis (working map)
  TILE_SYMBOLS = {
    # Basic terrain tiles - verified from Map 002
    '.' => { layer1: 0, layer2: 0, layer3: 0 },           # Empty (passable)
    'g' => { layer1: 401, layer2: 0, layer3: 0 },         # Grass (most common in Map002, 73x)
    'G' => { layer1: 402, layer2: 0, layer3: 0 },         # Grass variant (28x in Map002)
    'w' => { layer1: 393, layer2: 0, layer3: 0 },         # Water (33x in Map002)
    'W' => { layer1: 393, layer2: 0, layer3: 0 },         # Deep water (same)
    't' => { layer1: 809, layer2: 0, layer3: 0 },         # Tree/wall (61x in Map002)
    'T' => { layer1: 801, layer2: 0, layer3: 0 },         # Tree variant (47x in Map002)
    'p' => { layer1: 808, layer2: 0, layer3: 0 },         # Path (58x in Map002)
    'P' => { layer1: 409, layer2: 0, layer3: 0 },         # Paved path (24x in Map002)
    'r' => { layer1: 403, layer2: 0, layer3: 0 },         # Rock (19x in Map002)
    'R' => { layer1: 800, layer2: 0, layer3: 0 },         # Rock variant (44x in Map002)
    's' => { layer1: 810, layer2: 0, layer3: 0 },         # Sand/special (17x in Map002)
    'S' => { layer1: 811, layer2: 0, layer3: 0 },         # Sand variant (14x in Map002)
    'f' => { layer1: 405, layer2: 0, layer3: 0 },         # Flower (7x in Map002)
    'F' => { layer1: 405, layer2: 0, layer3: 0 },         # Flower patch
    'b' => { layer1: 802, layer2: 0, layer3: 0 },         # Bridge (10x in Map002)
    'B' => { layer1: 803, layer2: 0, layer3: 0 },         # Bridge variant (7x in Map002)
    'd' => { layer1: 818, layer2: 0, layer3: 0 },         # Door/entrance (11x in Map002)
    'D' => { layer1: 819, layer2: 0, layer3: 0 },         # Door variant (11x in Map002)
    'l' => { layer1: 388, layer2: 0, layer3: 0 },         # Ledge (9x in Map002)
    'L' => { layer1: 385, layer2: 0, layer3: 0 },         # Ledge variant (9x in Map002)
    '#' => { layer1: 809, layer2: 0, layer3: 0 },         # Wall/impassable (same as tree)
    '~' => { layer1: 393, layer2: 0, layer3: 0 },         # Water edge (same as water)
    '^' => { layer1: 387, layer2: 0, layer3: 0 },         # Sign (7x in Map002)
    '*' => { layer1: 400, layer2: 0, layer3: 0 },         # Special tile (7x in Map002)
  }
  
  # Custom tile definitions (can be expanded)
  CUSTOM_TILES = {}
  
  def self.build_map_from_file(map_id, layout_file)
    return unless FileTest.exist?(layout_file)
    
    echoln("=" * 80)
    echoln("Building Map #{map_id} from layout: #{File.basename(layout_file)}")
    echoln("=" * 80)
    
    # Load or create map
    map = load_map(map_id)
    return unless map
    
    # Parse layout file
    layout_data = parse_layout_file(layout_file)
    return unless layout_data
    
    # Apply layout to map
    apply_layout_to_map(map, layout_data)
    
    # Resize map if needed
    ensure_map_size(map, layout_data[:width], layout_data[:height])
    
    # Save map
    save_map(map_id, map)
    
    echoln("=" * 80)
    echoln("SUCCESS: Map #{map_id} built successfully!")
    echoln("  Size: #{layout_data[:width]}x#{layout_data[:height]}")
    echoln("  Tileset: #{layout_data[:tileset] || 'default'}")
    echoln("=" * 80)
  end
  
  def self.parse_layout_file(filename)
    data = {
      width: 0,
      height: 0,
      tileset: nil,
      custom_tiles: {},
      layers: { layer1: [], layer2: [], layer3: [] }
    }
    
    File.open(filename, "r") do |file|
      mode = :header
      row_index = 0
      
      file.each_line do |line|
        line = line.chomp.strip
        
        # Skip empty lines
        next if line.empty?
        
        # Skip comments ONLY if not in layout mode
        next if mode != :layout && line.start_with?('#')
        
        # Parse header commands
        if line.start_with?('MAP:')
          # Already handled
        elsif line.start_with?('SIZE:')
          parts = line.split(':')[1].strip.split('x')
          data[:width] = parts[0].to_i
          data[:height] = parts[1].to_i
          echoln("  Parsed SIZE: #{data[:width]}x#{data[:height]}")
        elsif line.start_with?('TILESET:')
          data[:tileset] = line.split(':')[1].strip.to_i
        elsif line.start_with?('TILE:')
          # Custom tile definition: TILE: X = layer1:123, layer2:456, layer3:0
          parse_custom_tile(line, data[:custom_tiles])
        elsif line.start_with?('LAYOUT:')
          mode = :layout
          echoln("  Switched to LAYOUT mode")
        elsif mode == :layout
          # Parse layout row
          if row_index == 15
            echoln("  DEBUG: Parsing row 15, line='#{line}'")
          end
          parse_layout_row(line, row_index, data)
          row_index += 1
          data[:height] = [data[:height], row_index].max
        end
      end
      echoln("  Total rows parsed: #{row_index}")
    end
    
    data
  end
  
  def self.parse_custom_tile(line, custom_tiles)
    # Format: TILE: X = layer1:123, layer2:456, layer3:0
    match = line.match(/TILE:\s*(\S)\s*=\s*(.+)/)
    return unless match
    
    symbol = match[1]
    layers_str = match[2]
    
    tile_data = { layer1: 0, layer2: 0, layer3: 0 }
    layers_str.split(',').each do |layer_def|
      layer_def.strip!
      if layer_def =~ /layer(\d):(\d+)/
        layer_num = $1.to_i
        tile_id = $2.to_i
        tile_data["layer#{layer_num}".to_sym] = tile_id
      end
    end
    
    custom_tiles[symbol] = tile_data
    echoln("  Registered custom tile '#{symbol}' = #{tile_data.inspect}")
  end
  
  def self.parse_layout_row(line, row, data)
    line.each_char.with_index do |char, col|
      tile = TILE_SYMBOLS[char] || CUSTOM_TILES[char] || TILE_SYMBOLS['.']
      
      # Debug: Show tile mapping
      if row == 15 && col == 14
        echoln("DEBUG: Row #{row}, Col #{col}, Char '#{char}' => layer1:#{tile[:layer1]}")
      end
      
      data[:layers][:layer1][row] ||= []
      data[:layers][:layer2][row] ||= []
      data[:layers][:layer3][row] ||= []
      
      data[:layers][:layer1][row][col] = tile[:layer1]
      data[:layers][:layer2][row][col] = tile[:layer2]
      data[:layers][:layer3][row][col] = tile[:layer3]
      
      data[:width] = [data[:width], col + 1].max
    end
  end
  
  def self.apply_layout_to_map(map, layout_data)
    # Set tileset if specified
    map.tileset_id = layout_data[:tileset] if layout_data[:tileset]
    
    # Initialize or resize map data
    map.data = Table.new(layout_data[:width], layout_data[:height], 3)
    map.width = layout_data[:width]
    map.height = layout_data[:height]
    
    # Debug: Check what tiles are in the layout data
    test_row = 15
    test_col = 14
    if layout_data[:layers][:layer1][test_row]
      test_value = layout_data[:layers][:layer1][test_row][test_col]
      echoln("  DEBUG: Layout data at [#{test_row}][#{test_col}] = #{test_value}")
    else
      echoln("  DEBUG: Row #{test_row} is NIL!")
    end
    
    # Fill map data
    (0...layout_data[:height]).each do |y|
      (0...layout_data[:width]).each do |x|
        # Safely access layout data with nil checks
        layer1_row = layout_data[:layers][:layer1][y]
        layer2_row = layout_data[:layers][:layer2][y]
        layer3_row = layout_data[:layers][:layer3][y]
        
        map.data[x, y, 0] = (layer1_row && layer1_row[x]) || 0
        map.data[x, y, 1] = (layer2_row && layer2_row[x]) || 0
        map.data[x, y, 2] = (layer3_row && layer3_row[x]) || 0
      end
    end
    
    # Debug: Check what was written to map
    echoln("  DEBUG: Map data at [#{test_col}][#{test_row}][0] = #{map.data[test_col, test_row, 0]}")
    echoln("  Applied layout to map data (#{layout_data[:width]}x#{layout_data[:height]})")
  end
  
  def self.ensure_map_size(map, width, height)
    return if map.width >= width && map.height >= height
    
    old_width = map.width
    old_height = map.height
    new_width = [map.width, width].max
    new_height = [map.height, height].max
    
    echoln("  Resizing map from #{old_width}x#{old_height} to #{new_width}x#{new_height}")
    
    old_data = map.data
    new_data = Table.new(new_width, new_height, 3)
    
    # Copy existing data
    (0...old_width).each do |x|
      (0...old_height).each do |y|
        (0...3).each do |layer|
          new_data[x, y, layer] = old_data[x, y, layer]
        end
      end
    end
    
    map.data = new_data
    map.width = new_width
    map.height = new_height
  end
  
  def self.load_map(map_id)
    map_file = sprintf("Data/Map%03d.rxdata", map_id)
    if FileTest.exist?(map_file)
      return load_data(map_file)
    else
      echoln("WARNING: Map #{map_id} does not exist! Creating from template...")
      # Use Map002 as template (outdoor map)
      template_file = "Data/Map002.rxdata"
      if FileTest.exist?(template_file)
        template_map = load_data(template_file)
        template_map.events.clear
        echoln("  Created empty map from template")
        return template_map
      else
        echoln("ERROR: No template map found!")
        return nil
      end
    end
  end
  
  def self.save_map(map_id, map)
    map_file = sprintf("Data/Map%03d.rxdata", map_id)
    File.open(map_file, "wb") { |f| Marshal.dump(map, f) }
    echoln("  Saved Map #{map_id}")
  end
  
  # Build all .map files on plugin load
  def self.build_all_maps
    map_dir = "EventImporter"
    return unless FileTest.directory?(map_dir)
    
    map_files = Dir.glob("#{map_dir}/*.map").sort
    return if map_files.empty?
    
    echoln("\n" + "=" * 80)
    echoln("MAP BUILDER: Found #{map_files.length} map layout file(s)")
    echoln("=" * 80)
    
    map_files.each do |file|
      # Extract map ID from filename (e.g., map022.map -> 22)
      if File.basename(file) =~ /map(\d+)\.map/i
        map_id = $1.to_i
        build_map_from_file(map_id, file)
      end
    end
  end
end

# Auto-build maps when plugin loads
PluginManager.register({
  :name => "RMXP Map Builder",
  :version => "1.0.0",
  :credits => "AI Assistant",
  :link => "https://github.com/yourusername/map-builder"
})

# Build maps automatically on startup (before event import)
# This ensures maps exist before events are imported
MapBuilder.build_all_maps if defined?(MapBuilder)

#===============================================================================
# Debug Menu Integration
#===============================================================================

# Helper method to get maps with .map layout files
def pbGetMapsWithLayoutFiles
  map_dir = "EventImporter"
  return [] unless FileTest.directory?(map_dir)
  
  map_files = Dir.glob("#{map_dir}/*.map").sort
  maps = []
  
  map_files.each do |file|
    # Match map###.map or map###_something.map
    if File.basename(file) =~ /map(\d+)(?:_.*)?\.map/i
      map_id = $1.to_i
      map_name = pbGetMapNameFromId(map_id)
      maps << [map_id, map_name, file]
    end
  end
  
  maps
end

# Debug menu option - Build Map Layout
MenuHandlers.add(:debug_menu, :build_map, {
  "name"        => _INTL("Build Map Layout"),
  "parent"      => :main,
  "description" => _INTL("Build map terrain from .map layout files."),
  "effect"      => proc { |menu|
    # Get list of maps with layout files
    maps = pbGetMapsWithLayoutFiles
    
    if maps.empty?
      pbMessage(_INTL("No .map layout files found in EventImporter folder."))
      next
    end
    
    # Create choice list
    commands = []
    maps.each do |map_id, map_name, file|
      commands << _INTL("Map {1}: {2}", map_id, map_name)
    end
    commands << _INTL("Build ALL maps")
    commands << _INTL("Cancel")
    
    # Show selection
    choice = pbMessage(_INTL("Select which map to build:"), commands, -1)
    
    if choice >= 0 && choice < maps.length
      # Build single map
      map_id = maps[choice][0]
      layout_file = maps[choice][2]
      pbMessage(_INTL("Building Map {1} layout...", map_id))
      
      begin
        MapBuilder.build_map_from_file(map_id, layout_file)
        pbMessage(_INTL("Successfully built Map {1}!\nCheck Debug Window for details.", map_id))
        
        # Reload map if it's the current one
        if $game_map && $game_map.map_id == map_id
          # Save player position
          old_x = $game_player.x
          old_y = $game_player.y
          old_direction = $game_player.direction
          
          # Reload map data
          $game_map.setup($game_map.map_id)
          
          # Restore player position (keep same spot)
          if $game_player && old_x < $game_map.width && old_y < $game_map.height
            $game_player.moveto(old_x, old_y)
            $game_player.instance_variable_set(:@direction, old_direction) if old_direction
            echoln("  Player position kept at (#{old_x}, #{old_y})")
          else
            # Player was out of bounds, move to safe position
            center_x = $game_map.width / 2
            center_y = $game_map.height / 2
            $game_player.moveto(center_x, center_y) if $game_player
            echoln("  Player repositioned to center (#{center_x}, #{center_y})")
          end
          
          $scene.disposeSpritesets if $scene.respond_to?(:disposeSpritesets)
          $scene.createSpritesets if $scene.respond_to?(:createSpritesets)
          pbMessage(_INTL("Map {1} reloaded!", map_id))
        end
      rescue Exception => e
        pbMessage(_INTL("Build failed for Map {1}!\nError: {2}", map_id, e.message))
        echoln("Map build error: #{e.message}")
        echoln(e.backtrace.join("\n"))
      end
      
    elsif choice == maps.length
      # Build all maps
      pbMessage(_INTL("Building all map layouts..."))
      
      begin
        MapBuilder.build_all_maps
        pbMessage(_INTL("Successfully built {1} map(s)!\nCheck Debug Window for details.", maps.length))
        
        # Reload current map
        if $game_map
          $game_map.setup($game_map.map_id)
          $scene.disposeSpritesets if $scene.respond_to?(:disposeSpritesets)
          $scene.createSpritesets if $scene.respond_to?(:createSpritesets)
          pbMessage(_INTL("Current map reloaded!"))
        end
      rescue Exception => e
        pbMessage(_INTL("Build failed!\nError: {1}", e.message))
        echoln("Map build error: #{e.message}")
        echoln(e.backtrace.join("\n"))
      end
    end
  }
})

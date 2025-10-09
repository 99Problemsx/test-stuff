#===============================================================================
# RMXP Map Analyzer - Find Correct Tile IDs
# Version: 1.0.0
#===============================================================================
# This tool analyzes existing maps to find the most common tile IDs
# Used to discover correct tile IDs for the Map Builder
#===============================================================================

module MapAnalyzer
  def self.analyze_map(map_id)
    map_file = sprintf("Data/Map%03d.rxdata", map_id)
    unless FileTest.exist?(map_file)
      echoln("ERROR: Map file not found: #{map_file}")
      return
    end
    
    begin
      map_data = load_data(map_file)
      
      echoln("=" * 80)
      echoln("Map #{map_id} Analysis")
      echoln("=" * 80)
      echoln("Size: #{map_data.width} x #{map_data.height}")
      echoln("Tileset ID: #{map_data.tileset_id}")
      echoln("")
      
      # Count all unique tile combinations
      tile_counts = {}
      
      (0...map_data.width).each do |x|
        (0...map_data.height).each do |y|
          l1 = map_data.data[x, y, 0] || 0
          l2 = map_data.data[x, y, 1] || 0
          l3 = map_data.data[x, y, 2] || 0
          
          key = "#{l1},#{l2},#{l3}"
          tile_counts[key] ||= 0
          tile_counts[key] += 1
        end
      end
      
      # Sort by most common
      sorted_tiles = tile_counts.sort_by { |k, v| -v }
      
      echoln("Top 20 Most Common Tile Combinations:")
      echoln("-" * 80)
      sorted_tiles.first(20).each_with_index do |(tile_combo, count), index|
        l1, l2, l3 = tile_combo.split(',')
        percentage = (count.to_f / (map_data.width * map_data.height) * 100).round(1)
        echoln("#{index + 1}. Layer1:#{l1.ljust(4)} Layer2:#{l2.ljust(4)} Layer3:#{l3.ljust(4)} | Used #{count.to_s.rjust(5)}x (#{percentage}%%)")
      end
      
      echoln("")
      echoln("TILE_SYMBOLS suggestions:")
      echoln("-" * 80)
      sorted_tiles.first(10).each_with_index do |(tile_combo, count), index|
        l1, l2, l3 = tile_combo.split(',')
        next if l1 == "0" && l2 == "0" && l3 == "0"  # Skip empty tiles
        
        symbol = get_suggested_symbol(index)
        echoln("'#{symbol}' => { layer1: #{l1}, layer2: #{l2}, layer3: #{l3} },  # Used #{count}x")
      end
      
      echoln("=" * 80)
      
    rescue => e
      echoln("ERROR analyzing map: #{e.message}")
      echoln(e.backtrace.first)
    end
  end
  
  def self.get_suggested_symbol(index)
    symbols = ['g', 'w', 'p', 't', 'G', 'W', 'P', 'T', 'r', 's']
    symbols[index] || '?'
  end
  
  def self.compare_maps(map_id1, map_id2)
    echoln("=" * 80)
    echoln("Comparing Map #{map_id1} and Map #{map_id2}")
    echoln("=" * 80)
    
    analyze_map(map_id1)
    echoln("\n")
    analyze_map(map_id2)
  end
end

#===============================================================================
# Debug Menu Integration
#===============================================================================
MenuHandlers.add(:debug_menu, :analyze_map, {
  "name"        => _INTL("Analyze Map Tiles"),
  "parent"      => :main,
  "description" => _INTL("Analyze tile IDs used in current map."),
  "effect"      => proc { |menu|
    if !$game_map
      pbMessage(_INTL("No map loaded!"))
      next
    end
    map_id = $game_map.map_id
    MapAnalyzer.analyze_map(map_id)
  }
})

MenuHandlers.add(:debug_menu, :analyze_map002, {
  "name"        => _INTL("Analyze Map 002"),
  "parent"      => :main,
  "description" => _INTL("Analyze Map 002 for correct tile IDs."),
  "effect"      => proc { |menu|
    MapAnalyzer.analyze_map(2)
  }
})

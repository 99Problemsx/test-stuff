#===============================================================================
# Map Inspector - Shows tile IDs from existing maps
# Use this to find correct tile IDs for Map Builder
#===============================================================================

# Debug menu option - Inspect Map Tiles
MenuHandlers.add(:debug_menu, :inspect_map_tiles, {
  "name"        => _INTL("Inspect Map Tiles"),
  "parent"      => :main,
  "description" => _INTL("Shows tile IDs from current map position."),
  "effect"      => proc { |menu|
    if !$game_map
      pbMessage(_INTL("No map loaded!"))
      next
    end
    
    x = $game_player.x
    y = $game_player.y
    
    tile_l1 = $game_map.data[x, y, 0]
    tile_l2 = $game_map.data[x, y, 1]
    tile_l3 = $game_map.data[x, y, 2]
    
    message = _INTL("Map {1} - Position ({2}, {3})\n", $game_map.map_id, x, y)
    message += _INTL("Tileset: {1}\n\n", $game_map.tileset_id)
    message += _INTL("Layer 1: {1}\n", tile_l1)
    message += _INTL("Layer 2: {1}\n", tile_l2)
    message += _INTL("Layer 3: {1}\n\n", tile_l3)
    message += _INTL("Copy this to use in your .map file:\n")
    message += _INTL("TILE: X = layer1:{1}, layer2:{2}, layer3:{3}", tile_l1, tile_l2, tile_l3)
    
    pbMessage(message)
    
    # Also output to console
    echoln("=" * 80)
    echoln("Map Inspector - Position (#{x}, #{y})")
    echoln("=" * 80)
    echoln("Map ID: #{$game_map.map_id}")
    echoln("Tileset ID: #{$game_map.tileset_id}")
    echoln("Layer 1: #{tile_l1}")
    echoln("Layer 2: #{tile_l2}")
    echoln("Layer 3: #{tile_l3}")
    echoln("")
    echoln("For .map file:")
    echoln("TILE: X = layer1:#{tile_l1}, layer2:#{tile_l2}, layer3:#{tile_l3}")
    echoln("=" * 80)
  }
})

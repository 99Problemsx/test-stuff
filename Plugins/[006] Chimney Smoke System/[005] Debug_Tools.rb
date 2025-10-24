# ===============================================================================
# Debug Commands for Chimney Smoke System
# ===============================================================================

EventHandlers.add(:on_frame_update, :chimney_smoke_debug,
  proc {
    # Ctrl+Shift+C = Toggle Chimney Smoke Debug Info
    if Input.press?(Input::CTRL) && Input.press?(Input::SHIFT) && Input.trigger?(Input::C)
      count = 0
      msg = "Chimney Smoke System\\n"
      msg += "Map ID: #{$game_map.map_id}\\n"
      msg += "Time: #{PBDayNight.isNight? ? "NIGHT" : "DAY"}\\n\\n"
      msg += "Active Smokes on this map:\\n"
      
      GameData::ChimneySmoke.each do |smoke|
        next if smoke.map_id != $game_map.map_id
        count += 1
        visible = smoke.visible? ? "YES" : "NO"
        msg += "#{smoke.id}:\\n"
        msg += "  Position: (#{smoke.x}, #{smoke.y})\\n"
        msg += "  Visible: #{visible}\\n"
        msg += "  Day Only: #{smoke.day_only}\\n"
      end
      
      if count == 0
        msg += "(No smokes defined for this map)"
      else
        msg += "\\nTotal: #{count} smoke(s)"
      end
      
      pbMessage(msg)
    end
  }
)

# Helper to show current player position in pixels
EventHandlers.add(:on_frame_update, :chimney_smoke_position_debug,
  proc {
    # Ctrl+Shift+P = Show Player Position (for finding smoke positions)
    if Input.press?(Input::CTRL) && Input.press?(Input::SHIFT) && Input.trigger?(Input::P)
      x = ($game_player.x * Game_Map::TILE_WIDTH).round
      y = ($game_player.y * Game_Map::TILE_HEIGHT).round
      
      msg = "Player Position\\n"
      msg += "Tile: (#{$game_player.x}, #{$game_player.y})\\n"
      msg += "Pixel: (#{x}, #{y})\\n\\n"
      msg += "Use these pixel coordinates\\n"
      msg += "to position chimney smoke!"
      
      pbMessage(msg)
    end
  }
)

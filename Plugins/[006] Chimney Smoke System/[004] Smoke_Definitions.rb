# ===============================================================================
# Chimney Smoke Definitions
# ===============================================================================
# Define your chimney smokes here using pbAddChimneySmoke
# 
# Syntax:
# pbAddChimneySmoke(id, map_id, x, y, graphic, day_only, options)
#
# Parameters:
#   id        - Unique symbol ID (e.g., :purple_house_smoke)
#   map_id    - Map ID where the smoke appears
#   x         - Pixel X position (precise positioning)
#   y         - Pixel Y position (precise positioning)
#   graphic   - Character graphic filename (default: "smoke")
#   day_only  - Show only during daytime (default: true)
#   options   - Hash with additional settings:
#               :pattern   - Starting animation frame (0-3, default: 0)
#               :direction - Direction (2=down, 4=left, 6=right, 8=up, default: 8)
#               :speed     - Animation speed (frames per second, default: 4)
#               :opacity   - Opacity (0-255, default: 200)
#
# Example:
# pbAddChimneySmoke(:house1_smoke, 43, 256, 288, "smoke", true, {
#   direction: 8,
#   speed: 3,
#   opacity: 180
# })
# ===============================================================================

# Helper function to add chimney smoke easily
def pbAddChimneySmoke(id, map_id, x, y, graphic = "smoke", day_only = true, options = {})
  GameData::ChimneySmoke.register({
    :id => id,
    :map_id => map_id,
    :x => x,
    :y => y,
    :graphic => graphic,
    :day_only => day_only,
    :pattern => options[:pattern] || 0,
    :direction => options[:direction] || 8,
    :speed => options[:speed] || 4,
    :opacity => options[:opacity] || 200
  })
end

# ===============================================================================
# Your smoke definitions below:
# ===============================================================================

# Purple House on Map 43 (adjust X position to fix the offset)
# Original event position: 008/016 (tile coordinates)
# Tile to pixel: x = 8 * 32 = 256, y = 16 * 32 = 512
# Fine-tuned position for chimney

pbAddChimneySmoke(:purple_house_smoke, 43, 267, 460, "Object_Smoke_Chimney", true, {
  direction: 8,      # Up
  speed: 3,          # 3 FPS animation
  opacity: 200       # Semi-transparent
})

# Add more smoke definitions here as needed
# pbAddChimneySmoke(:another_house, map_id, x, y, "smoke", true)

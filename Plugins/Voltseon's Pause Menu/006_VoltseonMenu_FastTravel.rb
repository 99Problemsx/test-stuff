#===============================================================================
# Pokemon Flux Style Fast Travel for Voltseon's Pause Menu
# Compatible with Arcky's Region Map
#===============================================================================

#===============================================================================
# Fast Travel Scene - Flux Style
#===============================================================================
class Scene_FluxFastTravel
  def initialize(locations)
    @locations = locations
    @current_index = 0
  end
  
  def pbStartScene
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    
    # Background overlay
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["overlay"].bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 20, 220))
    
    # Title
    @sprites["title"] = BitmapSprite.new(Graphics.width, 60, @viewport)
    @sprites["title"].y = 20
    
    # Location display
    @sprites["locations"] = BitmapSprite.new(Graphics.width, Graphics.height - 120, @viewport)
    @sprites["locations"].y = 80
    
    # Instructions
    @sprites["help"] = BitmapSprite.new(Graphics.width, 40, @viewport)
    @sprites["help"].y = Graphics.height - 60
    
    pbRefresh
  end
  
  def pbRefresh
    # Clear bitmaps
    @sprites["title"].bitmap.clear
    @sprites["locations"].bitmap.clear
    @sprites["help"].bitmap.clear
    
    pbSetSystemFont(@sprites["title"].bitmap)
    pbSetSystemFont(@sprites["locations"].bitmap)
    pbSetSystemFont(@sprites["help"].bitmap)
    
    # Title
    title_text = _INTL("Fast Travel")
    base = Color.new(255, 255, 255)
    shadow = Color.new(80, 80, 100)
    pbDrawTextPositions(@sprites["title"].bitmap, 
      [[title_text, Graphics.width / 2, 10, 2, base, shadow, 1]]
    )
    
    # Draw location list
    visible_count = 7
    half = visible_count / 2
    start_y = 20
    
    (-half..half).each do |offset|
      index = (@current_index + offset) % @locations.length
      location = @locations[index]
      y_pos = start_y + ((offset + half) * 40)
      
      if offset == 0
        # Selected location - highlighted
        color = Color.new(100, 200, 255)
        text_color = Color.new(255, 255, 255)
        text_shadow = Color.new(0, 100, 150)
        
        # Draw selection box
        @sprites["locations"].bitmap.fill_rect(
          50, y_pos - 5, Graphics.width - 100, 35, color
        )
        
        pbDrawTextPositions(@sprites["locations"].bitmap,
          [[location[:name], Graphics.width / 2, y_pos + 5, 2, text_color, text_shadow, 1]]
        )
      else
        # Other locations - faded
        distance = offset.abs
        alpha = 255 - (distance * 40)
        text_color = Color.new(200, 200, 200, alpha)
        text_shadow = Color.new(50, 50, 50, alpha)
        
        pbDrawTextPositions(@sprites["locations"].bitmap,
          [[location[:name], Graphics.width / 2, y_pos + 5, 2, text_color, text_shadow, 0]]
        )
      end
    end
    
    # Help text
    help_text = _INTL("↑/↓: Select   ENTER: Travel   ESC: Cancel")
    pbDrawTextPositions(@sprites["help"].bitmap,
      [[help_text, Graphics.width / 2, 10, 2, Color.new(200, 200, 200), Color.new(50, 50, 50)]]
    )
  end
  
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end
  
  def pbEndScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
  
  def pbChoose
    pbStartScene
    loop do
      Graphics.update
      Input.update
      pbUpdate
      
      if Input.repeat?(Input::UP)
        pbPlayCursorSE
        @current_index = (@current_index - 1) % @locations.length
        pbRefresh
      elsif Input.repeat?(Input::DOWN)
        pbPlayCursorSE
        @current_index = (@current_index + 1) % @locations.length
        pbRefresh
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        result = @locations[@current_index]
        pbEndScene
        return result
      elsif Input.trigger?(Input::BACK)
        pbPlayCancelSE
        pbEndScene
        return nil
      end
    end
  end
end

#===============================================================================
# Get fly locations from Arcky's Region Map (if available)
#===============================================================================
def pbGetFastTravelLocations
  locations = []
  
  # Check if Arcky's Region Map is available
  if defined?(PokemonRegionMap_Scene)
    # Get locations from Arcky's system
    $PokemonGlobal.visitedMaps = {} if !$PokemonGlobal.visitedMaps
    
    $PokemonGlobal.visitedMaps.each do |map_id, visited|
      next if !visited
      metadata = GameData::MapMetadata.try_get(map_id)
      next if !metadata
      
      heal_spot = metadata.heal_spot
      next if !heal_spot || heal_spot.empty?
      
      town_map_pos = metadata.town_map_position
      next if !town_map_pos
      
      locations.push({
        name: metadata.real_name || metadata.name,
        map: map_id,
        x: heal_spot[1],
        y: heal_spot[2]
      })
    end
  else
    # Fallback: Use standard visited maps
    $PokemonGlobal.visitedMaps.each do |map_id, visited|
      next if !visited
      metadata = GameData::MapMetadata.try_get(map_id)
      next if !metadata || !metadata.heal_spot
      
      locations.push({
        name: metadata.real_name || metadata.name,
        map: map_id,
        x: metadata.heal_spot[1],
        y: metadata.heal_spot[2]
      })
    end
  end
  
  # Sort alphabetically
  locations.sort_by! { |loc| loc[:name] }
  
  return locations
end

#===============================================================================
# Fast Travel Function
#===============================================================================
def pbFastTravel
  locations = pbGetFastTravelLocations
  
  if locations.empty?
    pbMessage(_INTL("You haven't discovered any locations yet."))
    return false
  end
  
  # Open selection menu
  scene = Scene_FluxFastTravel.new(locations)
  choice = scene.pbChoose
  
  if choice
    # Confirm travel
    if pbConfirmMessage(_INTL("Travel to {1}?", choice[:name]))
      pbFadeOutIn {
        $game_temp.player_transferring = true
        $game_temp.player_new_map_id = choice[:map]
        $game_temp.player_new_x = choice[:x]
        $game_temp.player_new_y = choice[:y]
        $game_temp.player_new_direction = 2
        Graphics.update
        $game_player.moveto(choice[:x], choice[:y])
        $game_map.update
        $scene.transfer_player
        $game_map.autoplay
        $game_map.refresh
      }
      return true
    end
  end
  
  return false
end

#===============================================================================
# Add to Voltseon's Pause Menu
#===============================================================================
MenuHandlers.add(:pause_menu, :fast_travel, {
  "name"      => _INTL("Travel"),
  "order"     => 35,
  "condition" => proc { next $player && $player.badge_count >= 0 },
  "effect"    => proc { |menu|
    menu.pbHideMenu
    result = pbFastTravel
    menu.pbShowMenu
    next result
  }
})

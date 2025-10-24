#===============================================================================
# Simple Test for Wind Animation - Direct sprite test
#===============================================================================

def pbTestWindSprite
  return if !$scene.is_a?(Scene_Map)
  
  viewport = Spriteset_Map.viewport
  
  # Create a simple test sprite
  test_sprite = Sprite.new(viewport)
  test_sprite.bitmap = Bitmap.new("Graphics/Animations/Wind/wind1")
  test_sprite.x = Graphics.width / 2
  test_sprite.y = Graphics.height / 2
  test_sprite.z = 999
  test_sprite.visible = true
  test_sprite.opacity = 255
  
  pbMessage("Test sprite created at center. Should be visible now.")
  pbMessage("Press OK to dispose sprite.")
  
  test_sprite.dispose
  pbMessage("Sprite disposed.")
rescue => e
  pbMessage("Error: #{e.message}")
  pbMessage(e.backtrace.first)
end

def pbTestWindAnimation
  return if !$scene.is_a?(Scene_Map)
  
  begin
    # Create wind particle
    viewport = Spriteset_Map.viewport
    wind = Events::Animations::Wind.new(viewport)
    wind.x = Graphics.width / 2 - 100
    wind.y = Graphics.height / 2 - 100
    wind.z = 999
    wind.opacity = 255
    wind.visible = true
    
    pbMessage("Wind particle created. Press OK to start update loop.")
    
    # Update for 300 frames (5 seconds)
    300.times do
      Graphics.update
      Input.update
      wind.update
      break if Input.trigger?(Input::BACK)
    end
    
    wind.dispose
    pbMessage("Wind animation test complete!")
  rescue => e
    pbMessage("Error: #{e.message}")
    pbMessage(e.backtrace.first)
  end
end

# Add to debug menu
MenuHandlers.add(:debug_menu, :test_wind_sprite, {
  "name"        => _INTL("Test Wind Sprite (Simple)"),
  "parent"      => :field_menu,
  "description" => _INTL("Test if wind sprites can be displayed at all."),
  "effect"      => proc { pbTestWindSprite }
})

MenuHandlers.add(:debug_menu, :test_wind_full, {
  "name"        => _INTL("Test Wind Animation (Full)"),
  "parent"      => :field_menu,
  "description" => _INTL("Test the full wind animation for 5 seconds."),
  "effect"      => proc { pbTestWindAnimation }
})

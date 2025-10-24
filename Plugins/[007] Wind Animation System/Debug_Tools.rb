#===============================================================================
# Debug Tools for Wind Animation System
#===============================================================================

# Simple command to start wind animation on current map
def pbStartWindAnimation
  if $scene.is_a?(Scene_Map) && $scene.spriteset
    pbAddWindEffect
    pbMessage("Wind animation activated!")
  else
    pbMessage("Must be on the map to use this!")
  end
end

# Simple command to stop wind animation
def pbStopWindAnimation
  if $scene.is_a?(Scene_Map) && $scene.spriteset
    pbRemoveWindEffect
    pbMessage("Wind animation stopped!")
  else
    pbMessage("Must be on the map to use this!")
  end
end

#===============================================================================
# Add to Debug Menu
#===============================================================================
MenuHandlers.add(:debug_menu, :wind_animation, {
  "name"        => _INTL("Toggle Wind Animation"),
  "parent"      => :field_menu,
  "description" => _INTL("Start or stop the wind particle animation on this map."),
  "effect"      => proc {
    if $scene.spriteset && $scene.spriteset.wind_manager
      pbRemoveWindEffect
      pbMessage(_INTL("Wind animation stopped."))
    else
      pbAddWindEffect
      pbMessage(_INTL("Wind animation started!"))
    end
  }
})

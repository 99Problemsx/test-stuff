#===============================================================================
# Integration with Spriteset_Map
#===============================================================================
class Spriteset_Map
  attr_accessor :wind_manager

  alias wind_initialize initialize
  def initialize(map = nil)
    wind_initialize(map)
    @wind_manager = nil
    # Auto-start wind animation if map has WindAnimation flag
    if @map.metadata&.has_flag?("WindAnimation")
      @wind_manager = Events::Animations::WindManager.new(@@viewport1)
    end
  end

  alias wind_dispose dispose
  def dispose
    @wind_manager&.dispose
    @wind_manager = nil
    wind_dispose
  end

  alias wind_update update
  def update
    wind_update
    @wind_manager&.update
  end
end

#===============================================================================
# Helper methods to enable/disable wind animation
#===============================================================================
def pbAddWindEffect
  spriteset = $scene.spriteset
  return if !spriteset
  return if spriteset.wind_manager  # Already active
  
  spriteset.wind_manager = Events::Animations::WindManager.new(Spriteset_Map.viewport)
end

def pbRemoveWindEffect
  spriteset = $scene.spriteset
  return if !spriteset
  return if !spriteset.wind_manager
  
  spriteset.wind_manager.dispose
  spriteset.wind_manager = nil
end

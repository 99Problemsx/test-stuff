# ===============================================================================
# Integration with Scene_Map
# ===============================================================================

class Spriteset_Global
  attr_accessor :chimney_smoke
  
  alias chimney_smoke_update update
  def update
    chimney_smoke_update
    @chimney_smoke&.update
  end
  
  alias chimney_smoke_dispose dispose
  def dispose
    @chimney_smoke&.dispose
    chimney_smoke_dispose
  end
end

class Scene_Map
  alias chimney_smoke_createSpritesets createSpritesets
  def createSpritesets
    chimney_smoke_createSpritesets
    viewport = Spriteset_Map.viewport
    @spritesetGlobal.chimney_smoke = ChimneySmokeManager.new($game_map, viewport) if @spritesetGlobal && viewport
  end
  
  alias chimney_smoke_disposeSpritesets disposeSpritesets
  def disposeSpritesets
    # Dispose chimney smoke BEFORE disposing other spritesets
    if @spritesetGlobal && @spritesetGlobal.chimney_smoke && !@spritesetGlobal.chimney_smoke.disposed?
      @spritesetGlobal.chimney_smoke.dispose
      @spritesetGlobal.chimney_smoke = nil
    end
    chimney_smoke_disposeSpritesets
  end
  
  alias chimney_smoke_transfer_player transfer_player
  def transfer_player(cancelVehicles = true)
    chimney_smoke_transfer_player(cancelVehicles)
    # Refresh smoke when changing maps
    if @spritesetGlobal && @spritesetGlobal.chimney_smoke && !@spritesetGlobal.chimney_smoke.disposed?
      @spritesetGlobal.chimney_smoke.refresh
    end
  end
end

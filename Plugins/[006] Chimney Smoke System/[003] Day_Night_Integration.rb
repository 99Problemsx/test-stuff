# ===============================================================================
# Update chimney smoke when day/night changes
# ===============================================================================

# Hook into NightTilesetTracker if it exists
if defined?(NightTilesetTracker)
  module NightTilesetTracker
    class << self
      alias chimney_refresh_map_graphics_original refresh_map_graphics
      
      def refresh_map_graphics
        # Dispose old chimney smoke system
        if $scene.is_a?(Scene_Map) && $scene.spritesetGlobal && $scene.spritesetGlobal.chimney_smoke
          echoln("[Chimney Smoke] Refreshing for day/night change...")
          $scene.spritesetGlobal.chimney_smoke.dispose
          $scene.spritesetGlobal.chimney_smoke = nil
        end
        
        # Call original refresh (this recreates everything)
        chimney_refresh_map_graphics_original
      end
    end
  end
else
  # Fallback: Check for day/night changes independently
  module ChimneySmokeTracker
    @last_night_state = nil
    
    def self.check_and_update
      return if !$scene.is_a?(Scene_Map)
      return if !$game_map
      
      current_night = PBDayNight.isNight?
      
      # Initialize on first check
      if @last_night_state.nil?
        @last_night_state = current_night
        return
      end
      
      # If state changed, trigger refresh
      if @last_night_state != current_night
        echoln("[Chimney Smoke] Day/Night changed! (Night: #{current_night})")
        @last_night_state = current_night
        refresh_smoke
      end
    end
    
    def self.refresh_smoke
      return if !$scene.is_a?(Scene_Map)
      return if !$scene.spritesetGlobal
      return if !$scene.spritesetGlobal.chimney_smoke
      
      echoln("[Chimney Smoke] Refreshing smoke visibility...")
      $scene.spritesetGlobal.chimney_smoke.refresh
    end
    
    def self.reset
      @last_night_state = nil
    end
  end
  
  # Check for day/night changes every frame
  EventHandlers.add(:on_frame_update, :chimney_smoke_tracker,
    proc {
      ChimneySmokeTracker.check_and_update
    }
  )
  
  # Reset tracker when entering a new map
  EventHandlers.add(:on_enter_map, :chimney_smoke_reset,
    proc {
      ChimneySmokeTracker.reset
    }
  )
end

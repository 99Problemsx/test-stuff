#===============================================================================
# Battle Challenge Compatibility Fix for Derxwna's Transition System
#===============================================================================
# Fixes Battle Challenge crash when nil foe is passed to vs_wild_boss check.
# This removes and re-registers the animation with nil-safety.
#===============================================================================

# Remove the original registration
SpecialBattleIntroAnimations.remove("vs_wild_boss")

# Re-register with Battle Challenge compatibility
SpecialBattleIntroAnimations.register("vs_wild_boss", 90,
  proc { |battle_type, foe, location|
    next false if ![0, 2].include?(battle_type)
    # Battle Challenge passes nil for foe - skip if no opponents
    next false if !foe || foe.empty?
    
    species = foe[0].species
    form    = foe[0].form
    base_path = "Graphics/Transitions/DTS/PTs"
    has_form_graphic = pbResolveBitmap("#{base_path}/Wild_#{species}_#{form}")
    has_species_graphic = pbResolveBitmap("#{base_path}/Wild_#{species}")
    
    next has_form_graphic || has_species_graphic
  },
  proc { |viewport, battle_type, foe, location|
    $game_temp.transition_animation_data = [foe[0].species, foe[0].form]
    
    # Determine filenames of graphics to be used
    species        = foe[0].species
    form           = foe[0].form
    bg_name        = $game_temp.get_vs_transition_bg
    bg_graphic     = sprintf("DTS/BGs/BG%s", bg_name.to_s) rescue nil
    
    if pbResolveBitmap(sprintf("Graphics/Transitions/DTS/PTs/Wild_%s_%s", species.to_s, form.to_s))
      wld_graphic = sprintf("DTS/PTs/Wild_%s_%s", species.to_s, form.to_s) rescue nil
    elsif pbResolveBitmap(sprintf("Graphics/Transitions/DTS/PTs/Wild_%s", species.to_s))
      wld_graphic = sprintf("DTS/PTs/Wild_%s", species.to_s) rescue nil
    else
      wld_graphic = sprintf("DTS/PTs/Wild") rescue nil
    end
    
    bar_graphic    = sprintf("DTS/bars")
    
    # Create sprites
    viewport2 = Viewport.new(0, 0, Graphics.width, Graphics.height)
    viewport2.z = 200000
    
    bg = IconSprite.new(0, 0, viewport2)
    bg.setBitmap("Graphics/Transitions/" + bg_graphic)
    
    bars = IconSprite.new(0, 0, viewport2)
    bars.setBitmap("Graphics/Transitions/" + bar_graphic)
    
    wild = IconSprite.new(0, 0, viewport2)
    wild.setBitmap("Graphics/Transitions/" + wld_graphic)
    wild.ox = wild.bitmap.width / 2
    wild.oy = wild.bitmap.height / 2
    wild.x = Graphics.width / 2
    wild.y = Graphics.height / 2
    wild.opacity = 0
    wild.zoom_x = 1.5
    wild.zoom_y = 1.5
    
    # Animation sequence
    16.times do
      Graphics.update
      wild.opacity += 16
      wild.zoom_x -= 0.03125
      wild.zoom_y -= 0.03125
    end
    
    20.times do
      Graphics.update
    end
    
    8.times do
      Graphics.update
      wild.zoom_x += 0.125
      wild.zoom_y += 0.125
    end
    
    # Cleanup
    bg.dispose
    bars.dispose
    wild.dispose
    viewport2.dispose
    viewport.color = Color.black
    $game_temp.transition_animation_data = nil
  }
)

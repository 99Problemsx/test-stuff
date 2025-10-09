#===============================================================================
# Animated Pokemon System Compatibility for Species Intro
# Makes Pokemon sprites animated in the species introduction screen.
# Solution based on Luka S.J.'s recommendation
#===============================================================================

if defined?(PluginManager) && PluginManager.installed?("[DBK] Animated Pokémon System")
  
  class SpeciesIntro
    #---------------------------------------------------------------------------
    # Override create_picture_icon to use DeluxeBitmapWrapper
    #---------------------------------------------------------------------------
    def create_picture_icon(bitmap)
      # Wenn es ein DeluxeBitmapWrapper ist, erstelle AnimatedPictureWindow
      if bitmap.is_a?(DeluxeBitmapWrapper)
        ret = AnimatedPictureWindow.new(bitmap)
      else
        ret = PictureWindow.new(bitmap)
      end
      ret.x = (Graphics.width / 2) - (ret.width / 2)
      ret.y = ((Graphics.height - 96) / 2) - (ret.height / 2)
      return ret
    end
    
    #---------------------------------------------------------------------------
    # Override show to use animated sprites
    #---------------------------------------------------------------------------
    alias animated_show show
    def show
      if @mark_as_seen
        Bridge.register_as_seen(@species, @form, @gender, @shiny)
      end
      
      # Verwende GameData::Species.front_sprite_bitmap direkt!
      bitmap = GameData::Species.front_sprite_bitmap(@species, @form, @gender, @shiny, @shadow)
      
      Bridge.play_cry(@species, @form)
      if bitmap
        iconwindow = create_picture_icon(bitmap)
        Bridge.message(text_message) do
          iconwindow.update if iconwindow.respond_to?(:update)
        end
        iconwindow.dispose
      end
    end
  end
  
  #=============================================================================
  # AnimatedPictureWindow - wrapper für DeluxeBitmapWrapper mit Rahmen
  #=============================================================================
  class AnimatedPictureWindow < SpriteWindow_Base
    def initialize(deluxe_bitmap)
      @deluxe_bitmap = deluxe_bitmap
      
      # Initialisiere SpriteWindow mit den richtigen Dimensionen
      super(0, 0, @deluxe_bitmap.width + 32, @deluxe_bitmap.height + 32)
      
      # Setze das erste Frame als contents
      self.contents = @deluxe_bitmap.bitmap
    end
    
    def update
      super
      if @deluxe_bitmap
        @deluxe_bitmap.update  # Update animation frame
        self.contents = @deluxe_bitmap.bitmap  # Zeige aktuellen Frame
      end
    end
    
    def dispose
      @deluxe_bitmap.dispose if @deluxe_bitmap && !@deluxe_bitmap.disposed?
      @deluxe_bitmap = nil
      super
    end
  end
  
end

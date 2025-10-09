#===============================================================================
# Gegner HP-Prozentanzeige
# Zeigt die HP des Gegners als Prozentsatz neben oder unter der HP-Leiste an
#===============================================================================

# Einstellungen
module Settings
  # Position der Prozentanzeige für Gegner
  # :beside_bar - Neben der HP-Leiste
  # :below_bar  - Unter der HP-Leiste
  ENEMY_HP_PERCENTAGE_POSITION = :beside_bar
  
  # Textfarben für die Prozentanzeige
  ENEMY_HP_PERCENT_BASE_COLOR   = Color.new(248, 248, 248)
  ENEMY_HP_PERCENT_SHADOW_COLOR = Color.new(72, 72, 72)
end

#===============================================================================
# Erweitert die Databox-Klasse um HP-Prozentanzeige für Gegner
#===============================================================================
class Battle::Scene::PokemonDataBox < Sprite
  alias enemy_hp_percent_initializeOtherGraphics initializeOtherGraphics
  def initializeOtherGraphics(viewport)
    enemy_hp_percent_initializeOtherGraphics(viewport)
    
    # Erstelle ein Bitmap für die Prozentanzeige (nur für Gegner)
    if @battler.index.odd?
      @hpPercentText = BitmapSprite.new(64, 20, viewport)
      pbSetSmallFont(@hpPercentText.bitmap)
      @hpPercentText.z = 200  # Hoher Z-Wert damit es über der Databox liegt
      @sprites["hpPercentText"] = @hpPercentText
      Console.echo_li("HP Percent Display erstellt für Gegner Index: #{@battler.index}")
    end
  end
  
  alias enemy_hp_percent_x= x=
  def x=(value)
    self.enemy_hp_percent_x=(value)
    if @hpPercentText
      case Settings::ENEMY_HP_PERCENTAGE_POSITION
      when :beside_bar
        # Neben der HP-Leiste (rechts)
        if @style
          @hpPercentText.x = value + @hpOffsetXY[0] + @hpBarBitmap.width + 4
        else
          @hpPercentText.x = value + @spriteBaseX + 102 + @hpBarBitmap.width + 4
        end
      when :below_bar
        # Unter der HP-Leiste (zentriert)
        if @style
          @hpPercentText.x = value + @hpOffsetXY[0] + (@hpBarBitmap.width / 2) - 16
        else
          @hpPercentText.x = value + @spriteBaseX + 102 + (@hpBarBitmap.width / 2) - 16
        end
      end
    end
  end
  
  alias enemy_hp_percent_y= y=
  def y=(value)
    self.enemy_hp_percent_y=(value)
    if @hpPercentText
      case Settings::ENEMY_HP_PERCENTAGE_POSITION
      when :beside_bar
        # Neben der HP-Leiste (vertikal zentriert)
        if @style
          @hpPercentText.y = value + @hpOffsetXY[1] + 5
        else
          @hpPercentText.y = value + 40 + 5
        end
      when :below_bar
        # Unter der HP-Leiste
        if @style
          @hpPercentText.y = value + @hpOffsetXY[1] + (@hpBarBitmap.height / 3) + 2
        else
          @hpPercentText.y = value + 40 + (@hpBarBitmap.height / 3) + 2
        end
      end
    end
  end
  
  alias enemy_hp_percent_z= z=
  def z=(value)
    self.enemy_hp_percent_z=(value)
    @hpPercentText.z = value + 50 if @hpPercentText  # Deutlich höherer Z-Wert
  end
  
  alias enemy_hp_percent_opacity= opacity=
  def opacity=(value)
    self.enemy_hp_percent_opacity=(value)
    @hpPercentText.opacity = value if @hpPercentText
  end
  
  alias enemy_hp_percent_visible= visible=
  def visible=(value)
    self.enemy_hp_percent_visible=(value)
    @hpPercentText.visible = value if @hpPercentText
  end
  
  alias enemy_hp_percent_color= color=
  def color=(value)
    self.enemy_hp_percent_color=(value)
    @hpPercentText.color = value if @hpPercentText
  end
  
  alias enemy_hp_percent_dispose dispose
  def dispose
    @hpPercentText&.dispose
    enemy_hp_percent_dispose
  end
  
  alias enemy_hp_percent_refresh_hp refresh_hp
  def refresh_hp
    enemy_hp_percent_refresh_hp
    
    # Aktualisiere die Prozentanzeige für Gegner
    if @hpPercentText && @battler.pokemon
      @hpPercentText.bitmap.clear
      
      # Berechne den HP-Prozentsatz
      hp_percentage = (self.hp.to_f / @battler.totalhp * 100).round
      hp_percentage = 0 if hp_percentage < 0
      hp_percentage = 100 if hp_percentage > 100
      
      # Debug-Ausgabe (ohne % im String wegen printf)
      Console.echo_li("HP Percent: #{hp_percentage} prozent (#{self.hp}/#{@battler.totalhp})")
      Console.echo_li("Position: x=#{@hpPercentText.x}, y=#{@hpPercentText.y}, z=#{@hpPercentText.z}")
      Console.echo_li("Visible: #{@hpPercentText.visible}, Opacity: #{@hpPercentText.opacity}")
      
      # Zeichne den Prozenttext
      text = "#{hp_percentage}%"
      textpos = [[text, 32, 2, :center, 
                  Settings::ENEMY_HP_PERCENT_BASE_COLOR, 
                  Settings::ENEMY_HP_PERCENT_SHADOW_COLOR]]
      pbDrawTextPositions(@hpPercentText.bitmap, textpos)
    end
  end
end

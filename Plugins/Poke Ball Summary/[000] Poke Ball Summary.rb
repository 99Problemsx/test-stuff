#===============================================================================
# Poke Ball Summary - Zeigt Fangchance permanent im Battle UI
#===============================================================================

module PokeBallSummary
  # Einstellungen
  SHOW_CATCH_RATE = true        # Zeige Fangchance in %
  SHOW_FOR_PLAYER = false       # Zeige auch für eigene Pokémon (normalerweise nur Gegner)
  USE_BEST_BALL = true          # Zeige Fangchance mit bestem Ball im Inventar
  
  # Position der Anzeige
  POSITION_X = 10               # X-Position (von links)
  POSITION_Y = 10               # Y-Position (von oben)
  
  # Finde den besten Ball im Inventar für dieses Pokémon
  def self.find_best_ball(battler)
    return :POKEBALL if !$bag
    
    best_ball = :POKEBALL
    best_rate = 0
    
    # Liste von Bällen die ignoriert werden sollen
    ignore_balls = [:MASTERBALL, :PARKBALL]  # Master Ball immer fangen, Park Ball nur in Parks
    
    # Durchsuche alle Bälle im Inventar
    GameData::Item.each do |item_data|
      next if !item_data.is_poke_ball?
      next if !$bag.has?(item_data.id)
      next if ignore_balls.include?(item_data.id)
      
      # Berechne catch rate für diesen Ball
      catch_rate = battler.pbCatchRate(item_data.id)
      
      if catch_rate > best_rate
        best_rate = catch_rate
        best_ball = item_data.id
      end
    end
    
    return best_ball
  end
end

#===============================================================================
# Berechne die Fangchance
#===============================================================================
class Battle::Battler
  def pbCatchRate(ball = :POKEBALL)
    return 100.0 if $DEBUG && Input.press?(Input::CTRL)
    
    # Basis Catch Rate
    catchRate = @pokemon.species_data.catch_rate
    
    # Ball Modifier - nutze die gleiche Methode wie das Spiel
    if !@pokemon.species_data.has_flag?("UltraBeast") || ball == :BEASTBALL
      catchRate = Battle::PokeBallEffects.modifyCatchRate(ball, catchRate, @battle, self)
    else
      catchRate = catchRate / 10.0
    end
    
    # Berechne x (catch_rate * HP-Modifier)
    # WICHTIG: Im Original wird catchRate MIT HP multipliziert, nicht separat!
    a = totalhp
    b = hp
    x = (((3 * a) - (2 * b)) * catchRate.to_f) / (3 * a)
    
    # Status Modifier
    if status == :SLEEP || status == :FROZEN
      x *= 2.5
    elsif status != :NONE
      x *= 1.5
    end
    
    x = x.floor
    x = 1 if x < 1
    
    # Wenn >= 255 oder Master Ball, automatisch 100%
    return 100.0 if x >= 255 || Battle::PokeBallEffects.isUnconditional?(ball, @battle, self)
    
    # Shake Check (Gen 6+ Formel)
    y = (65_536 / ((255.0 / x) ** 0.1875)).floor
    
    # Konvertiere zu Prozent (4 Shake Checks)
    shakeChance = y / 65_536.0
    catchPercent = (shakeChance ** 4 * 100).round(1)
    
    return catchPercent
  end
end

#===============================================================================
# Catch Rate Display Sprite
#===============================================================================
class CatchRateSprite < Sprite
  def initialize(battler_index, battle, viewport)
    super(viewport)
    @battler_index = battler_index
    @battle = battle
    @last_catch_rate = -1
    @last_hp = -1
    @last_status = nil
    @last_best_ball = nil
    
    # Erstelle Bitmap (größer für Ball-Empfehlung)
    self.bitmap = Bitmap.new(160, 70)
    self.x = PokeBallSummary::POSITION_X
    self.y = PokeBallSummary::POSITION_Y
    self.z = 250
    
    refresh
  end
  
  def battler
    return nil if !@battler_index || !@battle
    return @battle.battlers[@battler_index]
  end
  
  def refresh
    return if !battler || battler.fainted?
    
    # Prüfe ob Battler ein Pokemon hat
    return if !battler.pokemon
    
    # Finde besten Ball
    best_ball = PokeBallSummary.find_best_ball(battler)
    
    # Prüfe ob Update nötig ist
    current_hp = battler.hp
    current_status = battler.status
    catch_rate = battler.pbCatchRate(best_ball)
    
    return if @last_catch_rate == catch_rate && @last_hp == current_hp && 
              @last_status == current_status && @last_best_ball == best_ball
    
    @last_catch_rate = catch_rate
    @last_hp = current_hp
    @last_status = current_status
    @last_best_ball = best_ball
    
    # Clear bitmap
    self.bitmap.clear
    
    # Hintergrund (halbtransparent)
    self.bitmap.fill_rect(0, 0, 160, 70, Color.new(0, 0, 0, 180))
    
    # Border
    border_color = Color.new(255, 255, 255, 255)
    self.bitmap.fill_rect(0, 0, 160, 2, border_color)
    self.bitmap.fill_rect(0, 68, 160, 2, border_color)
    self.bitmap.fill_rect(0, 0, 2, 70, border_color)
    self.bitmap.fill_rect(158, 0, 2, 70, border_color)
    
    # Text Setup
    pbSetSystemFont(self.bitmap)
    self.bitmap.font.size = 16
    
    # HP Percentage
    hp_percent = (current_hp * 100.0 / battler.totalhp).round(1)
    hp_color = if hp_percent <= 25
      Color.new(255, 50, 50)    # Rot
    elsif hp_percent <= 50
      Color.new(255, 200, 50)   # Gelb
    else
      Color.new(50, 255, 50)    # Grün
    end
    
    self.bitmap.font.color = Color.new(200, 200, 200)
    self.bitmap.draw_text(8, 4, 70, 20, "HP:", 0)
    self.bitmap.font.color = hp_color
    self.bitmap.draw_text(40, 4, 110, 20, "#{hp_percent}%", 0)
    
    # Status Icon (klein)
    if current_status != :NONE
      status_color = case current_status
      when :SLEEP then Color.new(150, 150, 200)
      when :FROZEN then Color.new(100, 200, 255)
      when :PARALYSIS then Color.new(255, 200, 50)
      when :BURN then Color.new(255, 100, 50)
      when :POISON then Color.new(200, 100, 200)
      else Color.new(200, 200, 200)
      end
      self.bitmap.font.color = status_color
      self.bitmap.font.size = 12
      status_abbr = {
        :SLEEP => "SLP",
        :FROZEN => "FRZ",
        :PARALYSIS => "PAR",
        :BURN => "BRN",
        :POISON => "PSN"
      }
      self.bitmap.draw_text(100, 4, 50, 20, status_abbr[current_status] || "", 2)
      self.bitmap.font.size = 16
    end
    
    # Catch Rate mit Farbe
    catch_color = if catch_rate >= 75
      Color.new(50, 255, 50)    # Grün
    elsif catch_rate >= 50
      Color.new(100, 255, 100)  # Hellgrün
    elsif catch_rate >= 25
      Color.new(255, 200, 50)   # Gelb
    elsif catch_rate >= 10
      Color.new(255, 150, 50)   # Orange
    else
      Color.new(255, 50, 50)    # Rot
    end
    
    self.bitmap.font.color = Color.new(200, 200, 200)
    self.bitmap.draw_text(8, 24, 70, 20, "Catch:", 0)
    self.bitmap.font.color = catch_color
    self.bitmap.font.bold = true
    self.bitmap.draw_text(55, 24, 95, 20, "#{catch_rate}%", 0)
    self.bitmap.font.bold = false
    
    # Ball Empfehlung
    if PokeBallSummary::USE_BEST_BALL && best_ball
      ball_name = GameData::Item.get(best_ball).name
      # Kürze lange Namen
      ball_name = ball_name.gsub(" Ball", "").gsub("Ball", "")
      ball_name = "Poké" if best_ball == :POKEBALL
      
      self.bitmap.font.size = 14
      self.bitmap.font.color = Color.new(150, 200, 255)
      self.bitmap.draw_text(8, 44, 144, 20, "▸ #{ball_name}", 0)
      
      # Zeige Anzahl
      ball_count = $bag.quantity(best_ball)
      self.bitmap.font.color = Color.new(200, 200, 200)
      self.bitmap.draw_text(8, 44, 144, 20, "x#{ball_count}", 2)
      self.bitmap.font.size = 16
    end
  end
  
  def update
    super
    refresh if battler && !battler.fainted?
    self.visible = battler && !battler.fainted? && PokeBallSummary::SHOW_CATCH_RATE
  end
  
  def dispose
    self.bitmap&.dispose
    super
  end
end

#===============================================================================
# Battle Scene Integration
#===============================================================================
class Battle::Scene
  alias catchrate_pbInitSprites pbInitSprites
  def pbInitSprites
    catchrate_pbInitSprites
    @catchRateSprites = []
    
    # Erstelle Catch Rate Sprites für gegnerische Pokémon
    @battle.battlers.each do |b|
      next if !b || b.index.even? # Skip player side (index 0, 2, 4 = player)
      sprite = CatchRateSprite.new(b.index, @battle, @viewport)
      
      # Position anpassen für mehrere Gegner
      case b.index
      when 1 # Single battle enemy or first double battle enemy
        sprite.x = Graphics.width - 170
        sprite.y = 10
      when 3 # Second double battle enemy
        sprite.x = Graphics.width - 170
        sprite.y = 90  # Mehr Platz wegen größerer Box
      end
      
      @catchRateSprites.push(sprite)
    end
  end
  
  alias catchrate_pbUpdate pbUpdate
  def pbUpdate(cw = nil)
    catchrate_pbUpdate(cw)
    @catchRateSprites.each { |sprite| sprite.update if sprite && !sprite.disposed? }
  end
  
  alias catchrate_pbEndBattle pbEndBattle
  def pbEndBattle(result)
    @catchRateSprites.each { |sprite| sprite.dispose if sprite && !sprite.disposed? }
    @catchRateSprites.clear
    catchrate_pbEndBattle(result)
  end
end

# Ende der Datei


# ===============================================================================
# Chimney Smoke System - Animated smoke for houses
# For Pokémon Essentials v21.1
# ===============================================================================

module GameData
  class ChimneySmoke
    attr_reader :id
    attr_reader :map_id
    attr_reader :x              # Pixel X position (can be decimal for precise positioning)
    attr_reader :y              # Pixel Y position
    attr_reader :graphic        # Graphic filename (in Graphics/Characters/)
    attr_reader :day_only       # Show only during day
    attr_reader :pattern        # Animation pattern (0-3)
    attr_reader :direction      # Direction facing (2,4,6,8)
    attr_reader :speed          # Animation speed
    attr_reader :opacity        # Opacity (0-255)

    DATA = {}

    extend ClassMethodsSymbols
    include InstanceMethods

    def self.load; end
    def self.save; end

    def self.register(hash)
      id = hash[:id]
      DATA[id] = self.new(hash)
    end

    def initialize(hash)
      @id         = hash[:id]
      @map_id     = hash[:map_id]     || 0
      @x          = hash[:x]          || 0
      @y          = hash[:y]          || 0
      @graphic    = hash[:graphic]    || "smoke"
      @day_only   = hash[:day_only]   || true
      @pattern    = hash[:pattern]    || 0
      @direction  = hash[:direction]  || 8
      @speed      = hash[:speed]      || 4
      @opacity    = hash[:opacity]    || 200
    end

    # Check if smoke should be visible
    def visible?
      return false if @day_only && PBDayNight.isNight?
      return true
    end
  end
end

# ===============================================================================
# Chimney Smoke Sprite - Handles display and animation
# ===============================================================================

class ChimneySmoke_Sprite
  attr_accessor :x
  attr_accessor :y
  
  def initialize(data, viewport)
    @data = data
    @viewport = viewport
    @sprite = Sprite.new(viewport)
    @sprite.z = 50  # Above events but below weather
    @sprite.opacity = data.opacity
    @sprite.visible = true
    
    @disposed = false
    @pattern = data.pattern
    @direction = data.direction
    @frame_count = 0
    @animation_speed = data.speed
    
    echoln("[Chimney Smoke] Creating sprite for #{data.id} at (#{data.x}, #{data.y})")
    
    load_graphic
    update_position
    update_graphic
    
    echoln("[Chimney Smoke] Sprite created. Visible: #{@sprite.visible}, Opacity: #{@sprite.opacity}, Z: #{@sprite.z}")
  end
  
  def load_graphic
    begin
      graphic_path = "Graphics/Characters/" + @data.graphic
      echoln("[Chimney Smoke] Loading graphic: #{graphic_path}")
      @character_bitmap = AnimatedBitmap.new(graphic_path)
      @cw = @character_bitmap.width / 4   # 4 patterns
      @ch = @character_bitmap.height / 4  # 4 directions
      echoln("[Chimney Smoke] Graphic loaded successfully! Size: #{@cw}x#{@ch} per frame")
    rescue => e
      echoln("[Chimney Smoke] ERROR: Could not load graphic: #{@data.graphic}")
      echoln("[Chimney Smoke] Error message: #{e.message}")
      @character_bitmap = nil
      @cw = 32
      @ch = 32
    end
  end
  
  def update_position
    return if !$game_map
    
    # Convert pixel position to screen position
    screen_x = @data.x - ($game_map.display_x / Game_Map::X_SUBPIXELS).round
    screen_y = @data.y - ($game_map.display_y / Game_Map::Y_SUBPIXELS).round
    
    @sprite.x = screen_x
    @sprite.y = screen_y
  end
  
  def update_graphic
    return if !@character_bitmap
    
    # Calculate pattern based on frame count
    if @animation_speed > 0
      @frame_count += 1
      if @frame_count >= Graphics.frame_rate / @animation_speed
        @frame_count = 0
        @pattern = (@pattern + 1) % 4
      end
    end
    
    # Calculate source rect based on direction and pattern
    direction_index = case @direction
      when 2 then 0  # Down
      when 4 then 1  # Left
      when 6 then 2  # Right
      when 8 then 3  # Up
      else 0
    end
    
    sx = @pattern * @cw
    sy = direction_index * @ch
    
    @sprite.bitmap = @character_bitmap.bitmap if !@sprite.bitmap
    @sprite.src_rect.set(sx, sy, @cw, @ch)
  end
  
  def update
    return if disposed?
    update_position
    update_graphic
    
    # Check visibility
    if @data.visible?
      @sprite.visible = true
    else
      @sprite.visible = false
    end
  end
  
  def dispose
    return if disposed?
    @sprite.bitmap = nil if @sprite.bitmap
    @sprite.dispose
    @character_bitmap.dispose if @character_bitmap
    @disposed = true
    echoln("[Chimney Smoke] Sprite disposed for #{@data.id}")
  end
  
  def disposed?
    return @disposed
  end
end

# ===============================================================================
# Chimney Smoke Manager - Manages all smoke sprites
# ===============================================================================

class ChimneySmokeManager
  def initialize(map, viewport)
    @map = map
    @viewport = viewport
    @sprites = []
    @disposed = false
    
    setup_smokes
  end
  
  def setup_smokes
    # Dispose old sprites first
    @sprites.each { |sprite| sprite.dispose if sprite && !sprite.disposed? }
    @sprites.clear
    
    echoln("[Chimney Smoke] Setting up smokes for map #{@map.map_id}")
    echoln("[Chimney Smoke] Total registered smokes: #{GameData::ChimneySmoke::DATA.length}")
    
    # Load all smoke data for current map
    count = 0
    GameData::ChimneySmoke.each do |smoke_data|
      echoln("[Chimney Smoke] Checking smoke #{smoke_data.id} on map #{smoke_data.map_id}")
      next if smoke_data.map_id != @map.map_id
      sprite = ChimneySmoke_Sprite.new(smoke_data, @viewport)
      @sprites.push(sprite)
      count += 1
      echoln("[Chimney Smoke] Added smoke at (#{smoke_data.x}, #{smoke_data.y}) on map #{smoke_data.map_id}")
    end
    
    echoln("[Chimney Smoke] Total smokes added: #{count}")
  end
  
  def update
    return if disposed?
    @sprites.each { |sprite| sprite.update }
  end
  
  def refresh
    setup_smokes
  end
  
  def dispose
    return if disposed?
    echoln("[Chimney Smoke] Disposing manager with #{@sprites.length} sprites")
    @sprites.each { |sprite| sprite.dispose if sprite && !sprite.disposed? }
    @sprites.clear
    @disposed = true
    echoln("[Chimney Smoke] Manager disposed")
  end
  
  def disposed?
    return @disposed
  end
end

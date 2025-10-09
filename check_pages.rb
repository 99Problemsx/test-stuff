# Minimal RPG class definitions for reading .rxdata files
module RPG
  class Map
    attr_accessor :tileset_id, :width, :height, :autoplay_bgm, :bgm
    attr_accessor :autoplay_bgs, :bgs, :encounter_list, :encounter_step
    attr_accessor :data, :events
    
    def initialize(width, height)
      @tileset_id = 1
      @width = width
      @height = height
      @autoplay_bgm = false
      @bgm = RPG::AudioFile.new
      @autoplay_bgs = false
      @bgs = RPG::AudioFile.new("", 80)
      @encounter_list = []
      @encounter_step = 30
      @data = Table.new(width, height, 3)
      @events = {}
    end
  end
  
  class AudioFile
    attr_accessor :name, :volume, :pitch
    
    def initialize(name = "", volume = 100, pitch = 100)
      @name = name
      @volume = volume
      @pitch = pitch
    end
  end
  
  class Event
    attr_accessor :id, :name, :x, :y, :pages
    def initialize(x, y)
      @id = 0
      @name = ""
      @x = x
      @y = y
      @pages = [RPG::Event::Page.new]
    end
    
    class Page
      attr_accessor :condition, :graphic, :move_type, :move_speed
      attr_accessor :move_frequency, :move_route, :walk_anime, :step_anime
      attr_accessor :direction_fix, :through, :always_on_top, :trigger, :list
      
      def initialize
        @condition = RPG::Event::Page::Condition.new
        @graphic = RPG::Event::Page::Graphic.new
        @move_type = 0
        @move_speed = 3
        @move_frequency = 3
        @move_route = RPG::MoveRoute.new
        @walk_anime = true
        @step_anime = false
        @direction_fix = false
        @through = false
        @always_on_top = false
        @trigger = 0
        @list = [RPG::EventCommand.new]
      end
      
      class Condition
        attr_accessor :switch1_valid, :switch2_valid, :variable_valid
        attr_accessor :self_switch_valid, :switch1_id, :switch2_id
        attr_accessor :variable_id, :variable_value, :self_switch_ch
        
        def initialize
          @switch1_valid = false
          @switch2_valid = false
          @variable_valid = false
          @self_switch_valid = false
          @switch1_id = 1
          @switch2_id = 1
          @variable_id = 1
          @variable_value = 0
          @self_switch_ch = "A"
        end
      end
      
      class Graphic
        attr_accessor :tile_id, :character_name, :character_hue
        attr_accessor :direction, :pattern, :opacity, :blend_type
        
        def initialize
          @tile_id = 0
          @character_name = ""
          @character_hue = 0
          @direction = 2
          @pattern = 0
          @opacity = 255
          @blend_type = 0
        end
      end
    end
  end
  
  class EventCommand
    attr_accessor :code, :indent, :parameters
    
    def initialize(code = 0, indent = 0, parameters = [])
      @code = code
      @indent = indent
      @parameters = parameters
    end
  end
  
  class MoveRoute
    attr_accessor :repeat, :skippable, :list
    
    def initialize
      @repeat = true
      @skippable = false
      @list = [RPG::MoveCommand.new]
    end
  end
  
  class MoveCommand
    attr_accessor :code, :parameters
    
    def initialize(code = 0, parameters = [])
      @code = code
      @parameters = parameters
    end
  end
end

class Table
  attr_accessor :data
  
  def initialize(x, y = 1, z = 1)
    @xsize = x
    @ysize = y
    @zsize = z
    @data = Array.new(x * y * z, 0)
  end
  
  def _load(data)
    @data = data
  end
end

class Tone
  attr_accessor :red, :green, :blue, :gray
  
  def initialize(r = 0, g = 0, b = 0, a = 0)
    @red = r
    @green = g
    @blue = b
    @gray = a
  end
  
  def _load(data)
    @red, @green, @blue, @gray = data
  end
end

# Now load and check the map
require 'zlib'

map_file = "Data/Map003.rxdata"
File.open(map_file, "rb") do |f|
  map = Marshal.load(f)
  
  puts "=== Map 003 Events ==="
  map.events.each do |id, event|
    next if id <= 22  # Skip original events
    
    puts "\nEvent #{id}: #{event.name} at (#{event.x}, #{event.y})"
    puts "  Number of pages: #{event.pages.length}"
    
    event.pages.each_with_index do |page, idx|
      puts "  --- Page #{idx + 1} ---"
      puts "    Conditions:"
      puts "      Switch1: #{page.condition.switch1_valid ? "ID #{page.condition.switch1_id}" : "none"}"
      puts "      Switch2: #{page.condition.switch2_valid ? "ID #{page.condition.switch2_id}" : "none"}"
      puts "      Variable: #{page.condition.variable_valid ? "ID #{page.condition.variable_id} >= #{page.condition.variable_value}" : "none"}"
      puts "      Self Switch: #{page.condition.self_switch_valid ? page.condition.self_switch_ch : "none"}"
      puts "    Commands: #{page.list.length}"
      page.list.each_with_index do |cmd, i|
        puts "      #{i}: Code #{cmd.code} - #{cmd.parameters.inspect}"
      end
    end
  end
end

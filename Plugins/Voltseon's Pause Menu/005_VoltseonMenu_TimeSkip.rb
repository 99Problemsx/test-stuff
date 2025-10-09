#===============================================================================
# Time Skip Menu Entry for Voltseon's Pause Menu
# Integration with Unreal Time System (UTS)
#===============================================================================

#===============================================================================
# Time Selection Scene - Pokemon Flux Style
#===============================================================================
class Scene_TimeSelect
  def initialize(title, min_value, max_value, current_value, is_hour = true)
    @title = title
    @min_value = min_value
    @max_value = max_value
    @current_value = current_value
    @is_hour = is_hour
    @visible_count = 5 # How many values to show at once
  end
  
  def pbStartScene
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    
    # Semi-transparent background
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["overlay"].bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0, 180))
    
    # Main display bitmap
    @sprites["display"] = BitmapSprite.new(Graphics.width, 200, @viewport)
    @sprites["display"].y = (Graphics.height - 200) / 2
    
    pbRefresh
  end
  
  def pbRefresh
    bitmap = @sprites["display"].bitmap
    bitmap.clear
    pbSetSystemFont(bitmap)
    
    # Draw title
    base = Color.new(248, 248, 248)
    shadow = Color.new(96, 96, 96)
    title_y = 20
    pbDrawTextPositions(bitmap, [[@title, Graphics.width / 2, title_y, 2, base, shadow]])
    
    # Calculate visible values
    half = @visible_count / 2
    values_to_show = []
    
    (-half..half).each do |offset|
      val = @current_value + offset
      val = @max_value if val < @min_value
      val = @min_value if val > @max_value
      values_to_show.push(val)
    end
    
    # Draw time slots horizontally
    slot_width = Graphics.width / @visible_count
    center_y = 100
    
    values_to_show.each_with_index do |value, index|
      x = slot_width * index + (slot_width / 2)
      
      # Determine color and size based on selection
      if index == half # Center (selected)
        color = Color.new(80, 200, 255) # Bright blue
        text_color = Color.new(255, 255, 255)
        text_shadow = Color.new(0, 80, 120)
      else
        # Calculate fade based on distance from center
        distance = (index - half).abs
        alpha = 255 - (distance * 60)
        color = Color.new(150, 150, 150, alpha)
        text_color = Color.new(200, 200, 200, alpha)
        text_shadow = Color.new(50, 50, 50, alpha)
      end
      
      # Draw time value
      time_text = @is_hour ? sprintf("%02d:00", value) : sprintf(":%02d", value)
      
      if index == half
        # Larger text for selected
        pbDrawTextPositions(bitmap, [[time_text, x, center_y - 10, 2, text_color, text_shadow, 1]])
      else
        pbDrawTextPositions(bitmap, [[time_text, x, center_y, 2, text_color, text_shadow, 0]])
      end
    end
    
    # Draw slider bar
    bar_y = center_y + 40
    bar_width = Graphics.width - 80
    bar_x = 40
    
    # Background bar
    bitmap.fill_rect(bar_x, bar_y, bar_width, 4, Color.new(80, 80, 80))
    
    # Progress indicator
    progress = (@current_value - @min_value).to_f / (@max_value - @min_value)
    indicator_x = bar_x + (bar_width * progress).to_i
    bitmap.fill_rect(indicator_x - 3, bar_y - 8, 6, 20, Color.new(80, 200, 255))
  end
  
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end
  
  def pbEndScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
  
  def pbChoose
    pbStartScene
    loop do
      Graphics.update
      Input.update
      pbUpdate
      
      if Input.repeat?(Input::LEFT)
        pbPlayCursorSE
        @current_value -= 1
        @current_value = @max_value if @current_value < @min_value
        pbRefresh
      elsif Input.repeat?(Input::RIGHT)
        pbPlayCursorSE
        @current_value += 1
        @current_value = @min_value if @current_value > @max_value
        pbRefresh
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        pbEndScene
        return @current_value
      elsif Input.trigger?(Input::BACK)
        pbPlayCancelSE
        pbEndScene
        return nil
      end
    end
  end
end

#===============================================================================
# Time Skip Main Function
#===============================================================================
def pbTimeSkipMenu
  # Check if UTS is available
  if !defined?(UnrealTime) || !UnrealTime::ENABLED
    pbMessage(_INTL("Time skip is not available."))
    return
  end
  
  # Get current time
  current_time = pbGetTimeNow
  current_hour = current_time.hour
  current_min = current_time.min
  
  # Select hour
  scene = Scene_TimeSelect.new(_INTL("Wait until when?"), 0, 23, current_hour, true)
  new_hour = scene.pbChoose
  return if new_hour.nil?
  
  # Select minute
  scene = Scene_TimeSelect.new(_INTL("Select Minutes"), 0, 59, current_min, false)
  new_min = scene.pbChoose
  return if new_min.nil?
  
  # Confirm
  time_str = sprintf("%02d:%02d", new_hour, new_min)
  if pbConfirmMessage(_INTL("Skip to {1}?", time_str))
    UnrealTime.advance_to(new_hour, new_min, 0)
    pbMessage(_INTL("Time advanced to {1}!", time_str))
  end
end

#===============================================================================
# Register Time Skip in Pause Menu
#===============================================================================
MenuHandlers.add(:pause_menu, :time_skip, {
  "name"      => _INTL("Time"),
  "order"     => 100,
  "condition" => proc { next defined?(UnrealTime) && UnrealTime::ENABLED },
  "effect"    => proc { |menu|
    menu.pbHideMenu
    pbTimeSkipMenu
    menu.pbShowMenu
    next false
  }
})

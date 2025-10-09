#===============================================================================
# RMXP Event Importer
# Version 1.0
# Reads event definitions from text files and creates actual RMXP events
#===============================================================================

module EventImporter
  IMPORT_DIR = "EventImporter"
  
  # Called when the game starts to import all events
  def self.import_all_events
    return 0 unless FileTest.directory?(IMPORT_DIR)
    
    # Create debug log
    begin
      $debug_log = File.open("event_import_debug.log", "w")
      $debug_log.sync = true
      $debug_log.puts("=== Event Import Debug Log ===")
      $debug_log.puts("Working Dir: #{Dir.pwd}")
    rescue => e
      echoln("Failed to create debug log: #{e.message}")
    end
    
    imported_count = 0
    files = Dir.glob("#{IMPORT_DIR}/*.txt")
    echoln("Found #{files.length} file(s) in #{IMPORT_DIR}/")
    
    files.each do |file|
      begin
        echoln("Processing: #{File.basename(file)}")
        count = import_events_from_file(file)
        imported_count += count if count
        echoln("Imported #{count} events from #{File.basename(file)}")
      rescue => e
        echoln("ERROR importing #{File.basename(file)}: #{e.message}")
        echoln(e.backtrace.first(5).join("\n"))
      end
    end
    
    if imported_count > 0
      echoln("Successfully imported #{imported_count} events from #{IMPORT_DIR}/")
    else
      echoln("No events were imported")
    end
    
    # Close debug log
    if $debug_log
      $debug_log.puts("=== Import Complete: #{imported_count} events ===")
      $debug_log.close
    end
    
    return imported_count
  end
  
  # Import events from a single file
  def self.import_events_from_file(filename)
    return 0 unless FileTest.exist?(filename)
    
    echoln("Importing from: #{filename}")
    imported_count = 0
    current_map_id = nil
    current_map = nil
    map_data = {}
    
    File.open(filename, "r:UTF-8") do |file|
      file.each_line do |line|
        line = line.strip
        next if line.empty? || line.start_with?("#")
        
        # Parse map declaration
        if line =~ /^MAP\s*[:=]\s*(\d+)/i
          # Save previous map if exists
          if current_map_id && current_map && map_data[:event_count] > 0
            save_map(current_map_id, current_map)
            imported_count += map_data[:event_count] || 0
          end
          
          current_map_id = $1.to_i
          echoln("Loading Map #{current_map_id}")
          current_map = load_map(current_map_id)
          map_data = { event_count: 0 }
          next
        end
        
        # Parse event declaration
        if line =~ /^EVENT\s*[:=]/i
          if !current_map
            echoln("WARNING: EVENT found but no MAP declared!")
            next
          end
          event = parse_event_definition(file, line, current_map)
          if event
            add_event_to_map(current_map, event)
            map_data[:event_count] += 1
            echoln("  Added event: #{event.name} at (#{event.x}, #{event.y})")
          end
        end
      end
      
      # Save last map
      if current_map_id && current_map && map_data[:event_count] > 0
        save_map(current_map_id, current_map)
        imported_count += map_data[:event_count]
      end
    end
    
    echoln("Total events imported: #{imported_count}")
    return imported_count
  end
  
  # Import events for a specific map only
  def self.import_events_for_map(target_map_id)
    folder = "EventImporter"
    return 0 unless FileTest.directory?(folder)
    
    # Find all files for this map (try both formats: map32 and map032)
    patterns = [
      File.join(folder, "map#{target_map_id}*.txt"),
      File.join(folder, "map#{sprintf('%03d', target_map_id)}*.txt")
    ]
    
    files = []
    patterns.each do |pattern|
      files += Dir.glob(pattern, File::FNM_CASEFOLD)
    end
    files.uniq!
    files.reject! { |f| File.basename(f).start_with?('_') }
    
    if files.empty?
      echoln("No import files found for Map #{target_map_id}")
      return 0
    end
    
    echoln("=" * 50)
    echoln("Importing events for Map #{target_map_id}")
    echoln("Found #{files.length} file(s): #{files.map { |f| File.basename(f) }.join(', ')}")
    echoln("=" * 50)
    
    # Check if map file exists
    map_file = sprintf("Data/Map%03d.rxdata", target_map_id)
    unless FileTest.exist?(map_file)
      echoln("Error: Map file #{map_file} not found!")
      return 0
    end
    
    # Import from all matching files
    total_imported = 0
    current_map = load_map(target_map_id)
    event_count_before = current_map.events.size
    
    # CLEAR ALL EXISTING EVENTS to prevent duplicates
    echoln("Clearing #{event_count_before} existing event(s) before import")
    current_map.events.clear
    event_count_before = 0
    
    files.each do |filename|
      echoln("\nProcessing: #{File.basename(filename)}")
      
      File.open(filename, "r:UTF-8") do |file|
        found_target_map = false
        
        file.each_line do |line|
          line = line.strip
          next if line.empty? || line.start_with?("#")
          
          # Check if this is the MAP declaration for our target
          if line =~ /^MAP\s*[:=]\s*(\d+)/i
            map_id = $1.to_i
            if map_id == target_map_id
              found_target_map = true
              echoln("  Found MAP: #{map_id} declaration")
            else
              found_target_map = false
            end
            next
          end
          
          # Parse events only if we're in the target map section
          if found_target_map && line =~ /^EVENT\s*[:=]/i
            event = parse_event_definition(file, line, current_map)
            if event
              add_event_to_map(current_map, event)
              total_imported += 1
              echoln("  ✓ Imported: #{event.name} at (#{event.x}, #{event.y})")
            end
          end
        end
      end
    end
    
    # Save the map if events were imported
    if total_imported > 0
      save_map(target_map_id, current_map)
      
      # Delete all save files to prevent old map data from being loaded
      delete_save_files
      
      event_count_after = current_map.events.size
      echoln("=" * 50)
      echoln("SUCCESS: Imported #{total_imported} event(s)")
      echoln("Events before: #{event_count_before}, after: #{event_count_after}")
      echoln("IMPORTANT: All save files deleted to prevent conflicts")
      echoln("=" * 50)
    else
      echoln("=" * 50)
      echoln("WARNING: No events found in files for Map #{target_map_id}")
      echoln("=" * 50)
    end
    
    return total_imported
  end

  # Parse a single event definition
  def self.parse_event_definition(file, first_line, map)
    echoln("DEBUG: parse_event_definition - Starting to parse event")
    event = RPG::Event.new(0, 0)
    
    # IMPORTANT: Clear ALL default pages that RPG::Event.new creates
    event.pages.clear
    echoln("DEBUG: Cleared default pages")
    
    # Create our own clean page
    page = RPG::Event::Page.new
    echoln("DEBUG: Created new page")
    
    # CRITICAL FIX: Set to nil to prevent default graphic overlay
    # We'll only set a graphic if GRAPHIC command is found
    graphic_set = false  # Track if GRAPHIC was explicitly set
    
    # Initialize graphic to empty/nil state
    page.graphic.character_name = ""
    page.graphic.character_hue = 0
    page.graphic.direction = 2
    page.graphic.pattern = 0
    page.graphic.tile_id = 0
    page.graphic.opacity = 255
    page.graphic.blend_type = 0
    
    # Parse the first line (EVENT: name, x, y)
    if first_line =~ /EVENT\s*[:=]\s*(.+),\s*X\s*[:=]\s*(\d+),\s*Y\s*[:=]\s*(\d+)/i
      event.name = $1.strip
      event.x = $2.to_i
      event.y = $3.to_i
      echoln("DEBUG: Parsed event '#{event.name}' at (#{event.x}, #{event.y})")
    elsif first_line =~ /EVENT\s*[:=]\s*"([^"]+)"\s*,\s*(\d+)\s*,\s*(\d+)/i
      event.name = $1.strip
      event.x = $2.to_i
      event.y = $3.to_i
      echoln("DEBUG: Parsed event '#{event.name}' at (#{event.x}, #{event.y})")
    else
      echoln("WARNING: Invalid EVENT line: #{first_line}")
      return nil
    end
    
    # Parse additional properties
    commands = []
    echoln("DEBUG: Starting to parse event properties and commands")
    while line = file.gets
      line = line.strip
      # Break on empty line (end of event) or new event/map declaration
      if line.empty?
        echoln("DEBUG: Empty line - end of event")
        break
      end
      if line =~ /^(EVENT|MAP)\s*[:=]/i
        # Put the line back for the next iteration
        file.seek(-line.length - 2, IO::SEEK_CUR) rescue nil
        echoln("DEBUG: New EVENT/MAP - end of event")
        break
      end
      next if line.start_with?("#")  # Skip comments
      echoln("DEBUG: Processing line: #{line[0..80]}#{"..." if line.length > 80}")
      $debug_log.puts("    Parsing line: #{line}") if $debug_log
      
      case line
      when /^GRAPHIC\s*[:=]\s*(.+)/i
        graphic_name = $1.strip.gsub(/["']/, '')
        graphic_set = true  # Mark that GRAPHIC was explicitly set
        echoln("DEBUG: GRAPHIC command - #{graphic_name}")
        # Only check Followers if it's a single word in all caps (likely Pokemon name)
        # but NOT generic patterns like "NPC 01" or "trainer_BUGCATCHER"
        if graphic_name =~ /^[A-Z][A-Z_]*$/ && !graphic_name.include?(' ')
          # Check if Followers sprite exists
          follower_path = "Graphics/Characters/Followers/#{graphic_name}.png"
          if FileTest.exist?(follower_path)
            page.graphic.character_name = "Followers/#{graphic_name}"
            page.step_anime = true   # Enable step animation for Pokemon idle breathing animation
            page.walk_anime = true   # Enable walk animation
            page.direction_fix = false  # Allow direction changes
            echoln("DEBUG: Set Pokemon graphic: Followers/#{graphic_name} with animation")
          else
            page.graphic.character_name = graphic_name
            echoln("DEBUG: Set graphic: #{graphic_name}")
          end
        else
          page.graphic.character_name = graphic_name
          echoln("DEBUG: Set graphic: #{graphic_name}")
        end
      when /^TRIGGER\s*[:=]\s*(.+)/i
        page.trigger = parse_trigger($1.strip)
        echoln("DEBUG: Set TRIGGER = #{page.trigger}")
      when /^MOVE_TYPE\s*[:=]\s*(.+)/i
        page.move_type = parse_move_type($1.strip)
        echoln("DEBUG: Set MOVE_TYPE = #{page.move_type}")
      when /^MOVE_SPEED\s*[:=]\s*(\d+)/i
        page.move_speed = $1.to_i.clamp(1, 6)
        echoln("DEBUG: Set MOVE_SPEED = #{page.move_speed}")
      when /^MOVE_FREQ\s*[:=]\s*(\d+)/i
        page.move_frequency = $1.to_i.clamp(1, 6)
        echoln("DEBUG: Set MOVE_FREQ = #{page.move_frequency}")
      when /^DIRECTION\s*[:=]\s*(.+)/i
        page.graphic.direction = parse_direction($1.strip)
        echoln("DEBUG: Set DIRECTION = #{page.graphic.direction}")
      when /^THROUGH\s*[:=]\s*(true|yes|1)/i
        page.through = true
        echoln("DEBUG: Set THROUGH = true")
      when /^ALWAYS_ON_TOP\s*[:=]\s*(true|yes|1)/i
        page.always_on_top = true
        echoln("DEBUG: Set ALWAYS_ON_TOP = true")
      when /^DIRECTION_FIX\s*[:=]\s*(true|yes|1)/i
        page.direction_fix = true
        echoln("DEBUG: Set DIRECTION_FIX = true")
      when /^TEXT\s*[:=]\s*(.+)/i
        text = $1.strip.gsub(/^["']|["']$/, '')
        commands << create_text_command(text)
        echoln("DEBUG: Created TEXT command")
      when /^SCRIPT\s*[:=]\s*(.+)/i
        script = $1.strip
        commands << create_script_command(script)
        echoln("DEBUG: Created SCRIPT command")
      when /^SWITCH\s*[:=]\s*(\d+)\s*,\s*(ON|OFF)/i
        switch_id = $1.to_i
        value = ($2.upcase == "ON")
        commands << create_switch_command(switch_id, value)
        echoln("DEBUG: Created SWITCH command - #{switch_id} = #{value}")
      when /^VARIABLE\s*[:=]\s*(\d+)\s*,\s*(.+)/i
        commands << parse_variable($1.to_i, $2.strip)
        echoln("DEBUG: Created VARIABLE command - var #{$1}")
      when /^SELF_SWITCH\s*[:=]\s*([A-D])\s*,\s*(ON|OFF)/i
        self_switch = $1.upcase
        value = ($2.upcase == "ON")
        commands << create_self_switch_command(self_switch, value)
        echoln("DEBUG: Created SELF_SWITCH command - #{self_switch} = #{value}")
      when /^ITEM\s*[:=]\s*(.+?)(?:\s*,\s*(\d+))?$/i
        item = $1.strip.gsub(/^["']|["']$/, '').gsub(/^:/, '').upcase.to_sym
        quantity = $2 ? $2.to_i : 1
        commands << create_item_command(item, quantity)
        echoln("DEBUG: Created ITEM command - #{item} x#{quantity}")
      when /^POKEMON\s*[:=]\s*(.+?)(?:\s*,\s*(\d+))?$/i
        species = $1.strip.gsub(/^["']|["']$/, '').gsub(/^:/, '').upcase.to_sym
        level = $2 ? $2.to_i : 5
        commands << create_pokemon_command(species, level)
        echoln("DEBUG: Created POKEMON command - #{species} lv#{level}")
      when /^CHOICE\s*[:=]\s*(.+)/i
        # Support both pipe (|) and comma (,) as separators
        # Pipe is preferred for choices with commas in the text
        choice_text = $1
        separator = choice_text.include?('|') ? '|' : ','
        choices = choice_text.split(separator).map { |c| c.strip.gsub(/^["']|["']$/, '') }
        commands << create_choice_command(choices)
        echoln("DEBUG: Created CHOICE command - #{choices.length} options")
      when /^CONDITIONAL\s*[:=]\s*(.+)/i
        commands << parse_conditional($1.strip)
        echoln("DEBUG: Created CONDITIONAL command")
      when /^WAIT\s*[:=]\s*(\d+)/i
        frames = $1.to_i
        commands << create_wait_command(frames)
        echoln("DEBUG: Created WAIT command - #{frames} frames")
      when /^PLAY_SE\s*[:=]\s*(.+)/i
        se_name = $1.strip.gsub(/^["']|["']$/, '')
        commands << create_play_se_command(se_name)
        echoln("DEBUG: Created PLAY_SE command - #{se_name}")
      when /^PLAY_BGM\s*[:=]\s*(.+)/i
        bgm_name = $1.strip.gsub(/^["']|["']$/, '')
        commands << create_play_bgm_command(bgm_name)
        echoln("DEBUG: Created PLAY_BGM command - #{bgm_name}")
      when /^PLAY_ME\s*[:=]\s*(.+)/i
        me_name = $1.strip.gsub(/^["']|["']$/, '')
        commands << create_play_me_command(me_name)
        echoln("DEBUG: Created PLAY_ME command - #{me_name}")
      when /^FADEOUT_BGM\s*[:=]\s*(\d+)/i
        seconds = $1.to_i
        commands << RPG::EventCommand.new(242, 0, [seconds])
      when /^FADEOUT_BGS\s*[:=]\s*(\d+)/i
        seconds = $1.to_i
        commands << RPG::EventCommand.new(246, 0, [seconds])
      when /^SHOW_PICTURE\s*[:=]\s*(\d+)\s*,\s*([^,]+)(?:\s*,\s*(\d+)\s*,\s*(\d+))?/i
        pic_num = $1.to_i
        pic_name = $2.strip.gsub(/^["']|["']$/, '')
        x = $3 ? $3.to_i : 0
        y = $4 ? $4.to_i : 0
        echoln("DEBUG SHOW_PICTURE: num=#{pic_num}, name='#{pic_name}', x=#{x}, y=#{y}")
        $debug_log.puts("DEBUG SHOW_PICTURE: num=#{pic_num}, name='#{pic_name}', x=#{x}, y=#{y}") if $debug_log
        $debug_log.flush if $debug_log
        commands << create_show_picture_command(pic_num, pic_name, x, y)
      when /^MOVE_PICTURE\s*[:=]\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)/i
        pic_num = $1.to_i
        x = $2.to_i
        y = $3.to_i
        commands << create_move_picture_command(pic_num, x, y)
      when /^ERASE_PICTURE\s*[:=]\s*(\d+)/i
        pic_num = $1.to_i
        commands << RPG::EventCommand.new(235, 0, [pic_num])
      when /^LABEL\s*[:=]\s*(.+)/i
        label_name = $1.strip.gsub(/^["']|["']$/, '')
        commands << RPG::EventCommand.new(118, 0, [label_name])
      when /^JUMP_TO_LABEL\s*[:=]\s*(.+)/i
        label_name = $1.strip.gsub(/^["']|["']$/, '')
        commands << RPG::EventCommand.new(119, 0, [label_name])
      when /^LOOP_START/i
        commands << RPG::EventCommand.new(112, 0, [])
        echoln("DEBUG: Created LOOP_START command")
      when /^LOOP_END/i
        commands << RPG::EventCommand.new(413, 0, [])
        echoln("DEBUG: Created LOOP_END command")
      when /^BREAK_LOOP/i
        commands << RPG::EventCommand.new(113, 0, [])
        echoln("DEBUG: Created BREAK_LOOP command")
      when /^EXIT_EVENT/i
        commands << RPG::EventCommand.new(115, 0, [])
        echoln("DEBUG: Created EXIT_EVENT command")
      when /^ERASE_EVENT/i
        commands << RPG::EventCommand.new(116, 0, [])
        echoln("DEBUG: Created ERASE_EVENT command")
      when /^CALL_COMMON_EVENT\s*[:=]\s*(\d+)/i
        event_id = $1.to_i
        commands << RPG::EventCommand.new(117, 0, [event_id])
      when /^MONEY\s*[:=]\s*([+-]?\d+)/i
        amount = $1.to_i
        operation = amount >= 0 ? 0 : 1
        commands << RPG::EventCommand.new(125, 0, [operation, 0, amount.abs])
        echoln("DEBUG: Created MONEY command - #{amount >= 0 ? '+' : ''}#{amount}")
      when /^CHANGE_GOLD\s*[:=]\s*([+-]?\d+)/i
        amount = $1.to_i
        operation = amount >= 0 ? 0 : 1
        commands << RPG::EventCommand.new(125, 0, [operation, 0, amount.abs])
      when /^CHANGE_ITEMS\s*[:=]\s*(.+?)\s*,\s*([+-]?\d+)/i
        item_id = $1.strip.to_i
        amount = $2.to_i
        operation = amount >= 0 ? 0 : 1
        commands << RPG::EventCommand.new(126, 0, [item_id, operation, 0, amount.abs])
      when /^CHANGE_PARTY\s*[:=]\s*(.+?)\s*,\s*(ADD|REMOVE)/i
        actor_id = $1.strip.to_i
        operation = ($2.upcase == "ADD") ? 0 : 1
        commands << RPG::EventCommand.new(129, 0, [actor_id, operation, 0])
      when /^CHANGE_WEAPONS\s*[:=]\s*(.+?)\s*,\s*([+-]?\d+)/i
        weapon_id = $1.strip.to_i
        amount = $2.to_i
        operation = amount >= 0 ? 0 : 1
        commands << RPG::EventCommand.new(127, 0, [weapon_id, operation, 0, amount.abs])
      when /^CHANGE_ARMOR\s*[:=]\s*(.+?)\s*,\s*([+-]?\d+)/i
        armor_id = $1.strip.to_i
        amount = $2.to_i
        operation = amount >= 0 ? 0 : 1
        commands << RPG::EventCommand.new(128, 0, [armor_id, operation, 0, amount.abs])
      when /^CHANGE_HP\s*[:=]\s*(\d+)\s*,\s*([+-]?\d+)/i
        actor_id = $1.to_i
        amount = $2.to_i
        operation = amount >= 0 ? 0 : 1
        # params: [actor_id, operation, constant(0), value, allow_knockout(false)]
        # actor_id: 0=entire party, >0=specific actor
        commands << RPG::EventCommand.new(311, 0, [actor_id, operation, 0, amount.abs, false])
      when /^CHANGE_SP\s*[:=]\s*(\d+)\s*,\s*([+-]?\d+)/i
        actor_id = $1.to_i
        amount = $2.to_i
        operation = amount >= 0 ? 0 : 1
        commands << RPG::EventCommand.new(312, 0, [actor_id, operation, 0, amount.abs])
      when /^CHANGE_STATE\s*[:=]\s*(\d+)\s*,\s*(ADD|REMOVE)\s*,\s*(\d+)/i
        actor_id = $1.to_i
        operation = ($2.upcase == "ADD") ? 0 : 1
        state_id = $3.to_i
        commands << RPG::EventCommand.new(313, 0, [actor_id, operation, state_id])
      when /^CHANGE_LEVEL\s*[:=]\s*(\d+)\s*,\s*([+-]?\d+)/i
        actor_id = $1.to_i
        amount = $2.to_i
        operation = amount >= 0 ? 0 : 1
        commands << RPG::EventCommand.new(316, 0, [actor_id, operation, 0, amount.abs])
      when /^CHANGE_SKILLS\s*[:=]\s*(\d+)\s*,\s*(LEARN|FORGET)\s*,\s*(\d+)/i
        actor_id = $1.to_i
        operation = ($2.upcase == "LEARN") ? 0 : 1
        skill_id = $3.to_i
        commands << RPG::EventCommand.new(318, 0, [actor_id, operation, skill_id])
      when /^CHANGE_EXP\s*[:=]\s*(\d+)\s*,\s*([+-]?\d+)/i
        actor_id = $1.to_i
        amount = $2.to_i
        operation = amount >= 0 ? 0 : 1
        commands << RPG::EventCommand.new(315, 0, [actor_id, operation, 0, amount.abs])
      when /^CHANGE_EQUIPMENT\s*[:=]\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)/i
        actor_id = $1.to_i
        equip_type = $2.to_i  # 0=weapon, 1-4=armor slots
        item_id = $3.to_i
        commands << RPG::EventCommand.new(319, 0, [actor_id, equip_type, item_id])
      when /^CHANGE_ACTOR_NAME\s*[:=]\s*(\d+)\s*,\s*(.+)/i
        actor_id = $1.to_i
        name = $2.strip.gsub(/^["']|["']$/, '')
        commands << RPG::EventCommand.new(320, 0, [actor_id, name])
      when /^CHANGE_ACTOR_CLASS\s*[:=]\s*(\d+)\s*,\s*(\d+)/i
        actor_id = $1.to_i
        class_id = $2.to_i
        commands << RPG::EventCommand.new(321, 0, [actor_id, class_id])
      when /^CHANGE_ACTOR_GRAPHIC\s*[:=]\s*(\d+)\s*,\s*(.+?)(?:\s*,\s*(\d+))?(?:\s*,\s*(.+?))?(?:\s*,\s*(\d+))?/i
        actor_id = $1.to_i
        character_name = $2.strip.gsub(/^["']|["']$/, '')
        character_hue = $3 ? $3.to_i : 0
        battler_name = $4 ? $4.strip.gsub(/^["']|["']$/, '') : ""
        battler_hue = $5 ? $5.to_i : 0
        commands << RPG::EventCommand.new(322, 0, [actor_id, character_name, character_hue, battler_name, battler_hue])
      when /^CHANGE_ENEMY_HP\s*[:=]\s*(\d+)\s*,\s*([+-]?\d+)/i
        enemy_index = $1.to_i
        amount = $2.to_i
        operation = amount >= 0 ? 0 : 1
        # params: [enemy_index, operation, constant(0), value, allow_knockout(false)]
        commands << RPG::EventCommand.new(331, 0, [enemy_index, operation, 0, amount.abs, false])
      when /^CHANGE_ENEMY_SP\s*[:=]\s*(\d+)\s*,\s*([+-]?\d+)/i
        enemy_index = $1.to_i
        amount = $2.to_i
        operation = amount >= 0 ? 0 : 1
        commands << RPG::EventCommand.new(332, 0, [enemy_index, operation, 0, amount.abs])
      when /^CHANGE_ENEMY_STATE\s*[:=]\s*(\d+)\s*,\s*(ADD|REMOVE)\s*,\s*(\d+)/i
        enemy_index = $1.to_i
        operation = ($2.upcase == "ADD") ? 0 : 1
        state_id = $3.to_i
        commands << RPG::EventCommand.new(333, 0, [enemy_index, operation, state_id])
      when /^ENEMY_APPEAR\s*[:=]\s*(\d+)/i
        enemy_index = $1.to_i
        commands << RPG::EventCommand.new(335, 0, [enemy_index])
      when /^ENEMY_TRANSFORM\s*[:=]\s*(\d+)\s*,\s*(\d+)/i
        enemy_index = $1.to_i
        enemy_id = $2.to_i
        commands << RPG::EventCommand.new(336, 0, [enemy_index, enemy_id])
      when /^SHOW_BATTLE_ANIMATION\s*[:=]\s*(\d+)\s*,\s*(\d+)/i
        # Command 337: Show Battle Animation
        # params[0]: 0=enemy, 1=actor
        # params[1]: -1=entire troop/party, or specific index
        target_type = $1.to_i  # 0 or 1
        target_index = $2.to_i  # -1 for all, or specific index
        commands << RPG::EventCommand.new(337, 0, [target_type, target_index])
      when /^SHOW_ANIMATION\s*[:=]\s*(\d+)\s*,\s*(\d+)/i
        character = $1.to_i  # -1=player, 0=this event, >0=event ID
        animation_id = $2.to_i
        commands << RPG::EventCommand.new(207, 0, [character, animation_id])
      when /^CHANGE_FOG\s*[:=]\s*(.+?)(?:\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+))?/i
        # Command 204 with type=1 (Fog)
        # params: [type, name, hue, opacity, blend_type, zoom_x, zoom_y, sx, sy]
        fog_name = $1.strip.gsub(/^["']|["']$/, '')
        hue = $2 ? $2.to_i : 0
        opacity = $3 ? $3.to_i : 255
        blend_type = $4 ? $4.to_i : 0
        zoom_x = $5 ? $5.to_i : 200
        zoom_y = $6 ? $6.to_i : 200
        sx = $7 ? $7.to_i : 0
        sy = $8 ? $8.to_i : 0
        commands << RPG::EventCommand.new(204, 0, [1, fog_name, hue, opacity, blend_type, zoom_x, zoom_y, sx, sy])
      when /^CHANGE_PANORAMA\s*[:=]\s*(.+?)(?:\s*,\s*(\d+))?/i
        # Command 204 with type=0 (Panorama)
        # params: [type, name, hue]
        panorama_name = $1.strip.gsub(/^["']|["']$/, '')
        hue = $2 ? $2.to_i : 0
        commands << RPG::EventCommand.new(204, 0, [0, panorama_name, hue])
      when /^CHANGE_BATTLEBACK\s*[:=]\s*(.+)/i
        # Command 204 with type=2 (Battleback)
        # params: [type, name]
        battleback_name = $1.strip.gsub(/^["']|["']$/, '')
        commands << RPG::EventCommand.new(204, 0, [2, battleback_name])
      when /^SET_WEATHER\s*[:=]\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)/i
        # Command 236: Set Weather Effects
        # params: [type, power, duration]
        # type: 0=None, 1=Rain, 2=Storm, 3=Snow
        weather_type = $1.to_i
        power = $2.to_i
        duration = $3.to_i
        commands << RPG::EventCommand.new(236, 0, [weather_type, power, duration])
      when /^BATTLE_PROCESSING\s*[:=]\s*(\d+)/i
        troop_id = $1.to_i
        # Command 301: Battle Processing - only needs troop_id
        commands << RPG::EventCommand.new(301, 0, [troop_id])
      when /^SHOP_PROCESSING\s*[:=]\s*(.+)/i
        # Command 302: Shop Processing
        # First item: [type, id] where type: 0=item, 1=weapon, 2=armor
        # Additional items use command 605
        items_str = $1.split(',').map(&:strip)
        if items_str.length > 0
          # Parse first item (format: "TYPE:ID" or just "ID" defaulting to type 0)
          first_item = items_str[0]
          if first_item =~ /(\d+):(\d+)/
            item_type = $1.to_i
            item_id = $2.to_i
          else
            item_type = 0  # Default to item
            item_id = first_item.to_i
          end
          commands << RPG::EventCommand.new(302, 0, [item_type, item_id])
          
          # Add additional items as command 605
          items_str[1..-1].each do |item_str|
            if item_str =~ /(\d+):(\d+)/
              item_type = $1.to_i
              item_id = $2.to_i
            else
              item_type = 0
              item_id = item_str.to_i
            end
            commands << RPG::EventCommand.new(605, 0, [item_type, item_id])
          end
        end
      when /^NAME_INPUT\s*[:=]\s*(\d+)\s*,\s*(\d+)/i
        actor_id = $1.to_i
        max_chars = $2.to_i
        commands << RPG::EventCommand.new(303, 0, [actor_id, max_chars])
      when /^CHANGE_WINDOWSKIN\s*[:=]\s*(.+)/i
        windowskin_name = $1.strip.gsub(/^["']|["']$/, '')
        commands << RPG::EventCommand.new(131, 0, [windowskin_name])
      when /^CHANGE_BATTLE_BGM\s*[:=]\s*(.+)/i
        bgm_name = $1.strip.gsub(/^["']|["']$/, '')
        audio = RPG::AudioFile.new(bgm_name, 100, 100)
        commands << RPG::EventCommand.new(132, 0, [audio])
      when /^CHANGE_BATTLE_END_ME\s*[:=]\s*(.+)/i
        me_name = $1.strip.gsub(/^["']|["']$/, '')
        audio = RPG::AudioFile.new(me_name, 100, 100)
        commands << RPG::EventCommand.new(133, 0, [audio])
      when /^STOP_SE/i
        commands << RPG::EventCommand.new(251, 0, [])
      when /^MEMORIZE_BGM/i
        # RMXP uses 247 for both BGM and BGS memorize (combined command)
        commands << RPG::EventCommand.new(247, 0, [])
      when /^RESTORE_BGM/i
        # RMXP uses 248 for both BGM and BGS restore (combined command)
        commands << RPG::EventCommand.new(248, 0, [])
      when /^PLAY_BGS\s*[:=]\s*(.+)/i
        bgs_name = $1.strip.gsub(/^["']|["']$/, '')
        audio = RPG::AudioFile.new(bgs_name, 80, 100)
        commands << RPG::EventCommand.new(245, 0, [audio])
      when /^FADEOUT_BGS\s*[:=]\s*(\d+)/i
        seconds = $1.to_i
        commands << RPG::EventCommand.new(246, 0, [seconds])
      when /^RECOVER_ALL(?:\s*[:=]\s*(\d+))?/i
        # Command 314: Recover All
        # Parameters: [actor_id] where 0 = entire party, or specific actor ID
        # Automatically play heal ME (Music Effect) before recovering
        commands << RPG::EventCommand.new(249, 0, [RPG::AudioFile.new("Pkmn healing", 80, 100)])
        actor_id = $1 ? $1.to_i : 0  # Default to 0 (entire party) if not specified
        commands << RPG::EventCommand.new(314, 0, [actor_id])
        echoln("DEBUG: Created RECOVER_ALL command for actor #{actor_id}")
      when /^SET_EVENT_LOCATION\s*[:=]\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)/i
        event_id = $1.to_i
        x = $2.to_i
        y = $3.to_i
        commands << RPG::EventCommand.new(202, 0, [event_id, 0, x, y])
      when /^SCREEN_SHAKE\s*[:=]\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)/i
        power = $1.to_i
        speed = $2.to_i
        duration = $3.to_i
        commands << RPG::EventCommand.new(225, 0, [power, speed, duration])
      when /^SCREEN_FLASH\s*[:=]\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)(?:\s*,\s*(\d+))?/i
        r = $1.to_i
        g = $2.to_i
        b = $3.to_i
        a = $4.to_i
        duration = $5 ? $5.to_i : 20
        color = Color.new(r, g, b, a)
        commands << RPG::EventCommand.new(224, 0, [color, duration])
      when /^CHANGE_TRANSPARENT\s*[:=]\s*(ON|OFF)/i
        transparent = ($1.upcase == "ON")
        commands << RPG::EventCommand.new(208, 0, [transparent ? 0 : 1])
      when /^CHANGE_MENU_ACCESS\s*[:=]\s*(ENABLE|DISABLE)/i
        enable = ($1.upcase == "ENABLE")
        # params[0]: 0=Disable, 1=Enable
        commands << RPG::EventCommand.new(135, 0, [enable ? 1 : 0])
      when /^CHANGE_SAVE_ACCESS\s*[:=]\s*(ENABLE|DISABLE)/i
        enable = ($1.upcase == "ENABLE")
        # params[0]: 0=Disable, 1=Enable
        commands << RPG::EventCommand.new(134, 0, [enable ? 1 : 0])
      when /^CHANGE_ENCOUNTER\s*[:=]\s*(ENABLE|DISABLE)/i
        enable = ($1.upcase == "ENABLE")
        # params[0]: 0=Disable, 1=Enable
        commands << RPG::EventCommand.new(136, 0, [enable ? 1 : 0])
      when /^COMMENT\s*[:=]\s*(.+)/i
        comment = $1.strip
        commands << RPG::EventCommand.new(108, 0, [comment])
      when /^FADEOUT/i
        # Command 221: Prepare for Transition (Fadeout)
        commands << RPG::EventCommand.new(221, 0, [])
        echoln("DEBUG: Created FADEOUT command")
      when /^FADEIN/i
        # Command 222: Execute Transition (Fadein)
        # Parameters: [transition_name (string)]
        commands << RPG::EventCommand.new(222, 0, [""])
        echoln("DEBUG: Created FADEIN command")
      when /^WARP\s*[:=]\s*(.+)/i
        commands << parse_transfer($1.strip)
        echoln("DEBUG: Created WARP command (alias for TRANSFER)")
      when /^TRANSFER\s*[:=]\s*(.+)/i
        commands << parse_transfer($1.strip)
        echoln("DEBUG: Created TRANSFER command")
      when /^MOVE_ROUTE\s*[:=]\s*(.+)/i
        commands << parse_move_route($1.strip)
        echoln("DEBUG: Created MOVE_ROUTE command")
      when /^SET_MOVE_ROUTE\s*[:=]\s*(.+)/i
        commands << parse_move_route($1.strip)
        echoln("DEBUG: Created SET_MOVE_ROUTE command")
      when /^WAIT_FOR_MOVE/i
        # Command 210: Wait for Move's Completion
        commands << RPG::EventCommand.new(210, 0, [])
        echoln("DEBUG: Created WAIT_FOR_MOVE command")
      when /^CHANGE_SCREEN_TONE\s*[:=]\s*(.+)/i
        commands << parse_screen_tone($1.strip)
        echoln("DEBUG: Created CHANGE_SCREEN_TONE command")
      when /^NEW_PAGE/i
        # Finalize current page
        commands << RPG::EventCommand.new(0, 0, [])
        page.list = commands
        event.pages << page  # Add the current page
        echoln("DEBUG: NEW_PAGE - Finalized page #{event.pages.length}, starting page #{event.pages.length + 1}")
        # Create new page (don't add to array yet, will be added at the end)
        page = RPG::Event::Page.new
        # Clear default graphic for new page
        page.graphic.character_name = ""
        page.graphic.character_hue = 0
        page.graphic.direction = 2
        page.graphic.pattern = 0
        page.graphic.tile_id = 0
        commands = []
        echoln("DEBUG: Created new page #{event.pages.length + 1}")
      when /^CONDITION_SWITCH\s*[:=]\s*(\d+)/i
        page.condition.switch1_valid = true
        page.condition.switch1_id = $1.to_i
        echoln("DEBUG: Set CONDITION_SWITCH = #{$1}")
      when /^CONDITION_VARIABLE\s*[:=]\s*(\d+)\s*,\s*(\d+)/i
        page.condition.variable_valid = true
        page.condition.variable_id = $1.to_i
        page.condition.variable_value = $2.to_i
      when /^CONDITION_SELF_SWITCH\s*[:=]\s*([A-D])/i
        page.condition.self_switch_valid = true
        page.condition.self_switch_ch = $1.upcase
      else
        echoln("    WARNING: Unrecognized command: #{line}")
        $debug_log.puts("    WARNING: Unrecognized command: #{line}") if $debug_log
      end
    end
    
    # Finalize the last page - DON'T add terminator yet, let post-processing handle it
    echoln("DEBUG: Finalizing page - #{commands.length} commands before post-processing")
    
    # CRITICAL: Remove any nil commands before post-processing
    commands.compact!
    echoln("DEBUG: After removing nil commands - #{commands.length} commands")
    
    commands = fix_choice_branches(commands)  # Post-process to fix choice branch structure
    echoln("DEBUG: After fix_choice_branches - #{commands.length} commands")
    
    # CRITICAL: Remove any nil commands after fix_choice_branches
    commands.compact!
    echoln("DEBUG: After removing nil commands - #{commands.length} commands")
    
    commands = fix_conditional_structure(commands)  # NEW: Fix conditional indent and structure
    echoln("DEBUG: After fix_conditional_structure - #{commands.length} commands")
    
    # CRITICAL: Final nil removal before setting page.list
    commands.compact!
    echoln("DEBUG: After final nil removal - #{commands.length} commands")
    
    # ULTRA-CRITICAL: Verify NO nil commands exist and all have .indent
    nil_count = commands.count(nil)
    if nil_count > 0
      echoln("ERROR: Found #{nil_count} nil commands after compact! This should never happen!")
      commands.compact!  # Try one more time
    end
    
    # Verify all commands have required properties AND valid indent values
    commands.each_with_index do |cmd, idx|
      if cmd.nil?
        echoln("ERROR: Command at index #{idx} is nil!")
      elsif !cmd.respond_to?(:indent)
        echoln("ERROR: Command at index #{idx} (code #{cmd.code rescue 'unknown'}) doesn't have indent property!")
      elsif cmd.indent.nil?
        echoln("ERROR: Command at index #{idx} (code #{cmd.code}) has NIL indent! Fixing to 0...")
        cmd.indent = 0
      end
    end
    
    # CRITICAL: Ensure the LAST command is always code 0 at indent 0 (event terminator)
    # Remove any trailing code 0 commands first
    while commands.length > 0 && commands.last.code == 0
      commands.pop
      echoln("DEBUG: Removed trailing code 0 command")
    end
    
    # Now add THE FINAL terminator
    commands << RPG::EventCommand.new(0, 0, [])
    echoln("DEBUG: Added final terminator - total #{commands.length} commands")
    
    # DEBUGGING: Show the complete command structure
    echoln("DEBUG: === COMPLETE COMMAND STRUCTURE ===")
    commands.each_with_index do |cmd, idx|
      code_name = case cmd.code
        when 0 then "END"
        when 101 then "TEXT"
        when 102 then "CHOICE"
        when 111 then "IF"
        when 402 then "WHEN"
        when 411 then "ELSE"
        when 412 then "BRANCH_END"
        else cmd.code.to_s
        end
      echoln("  [#{idx}] indent=#{cmd.indent} code=#{cmd.code}(#{code_name}) params=#{cmd.parameters.inspect[0..50]}")
    end
    echoln("DEBUG: === END STRUCTURE ===")
    
    # Final verification
    echoln("DEBUG: Final command list has #{commands.length} commands, all verified non-nil with valid indents")
    
    page.list = commands
    
    # CRITICAL FIX: If no GRAPHIC was set, ensure character_name is truly empty
    # This prevents overlay of default NPC sprites on Pokemon
    if !graphic_set || page.graphic.character_name == ""
      # Create a completely blank graphic
      page.graphic = RPG::Event::Page::Graphic.new
      echoln("DEBUG: No graphic set - using blank graphic")
    end
    
    event.pages << page
    echoln("DEBUG: Event '#{event.name}' complete with #{event.pages.length} page(s)")
    
    return event
  end
  
  # Post-process commands to fix choice branch structures
  # Converts CHOICE command followed by When[X] commands into proper RMXP structure
  def self.fix_choice_branches(commands)
    echoln("DEBUG: fix_choice_branches - Processing #{commands.length} commands")
    result = []
    i = 0
    while i < commands.length
      cmd = commands[i]
      
      # Safety check: skip nil commands
      if cmd.nil?
        echoln("WARNING: Encountered nil command at index #{i} in fix_choice_branches, skipping")
        i += 1
        next
      end
      
      # Check if this is a Show Choices command (102)
      if cmd.code == 102
        echoln("DEBUG: Found CHOICE command (102) with #{cmd.parameters[0].length} options")
        result << cmd  # Add the Show Choices command
        choices = cmd.parameters[0]  # Get the choice text array
        num_choices = choices.length
        i += 1
        
        # Create array to hold commands for each choice branch
        # Initialize with empty arrays for all choices
        all_branches = Array.new(num_choices) { [] }
        
        # Collect commands and assign them to the correct branch
        current_choice_index = nil
        
        while i < commands.length
          next_cmd = commands[i]
          
          # Safety check: break if we hit a nil command
          if next_cmd.nil?
            echoln("WARNING: Encountered nil command at index #{i} while processing choice branches")
            break
          end
          
          if next_cmd.code == 402  # When [Choice X] - marks start of a choice branch
            # Get the choice index from parameters[0]
            current_choice_index = next_cmd.parameters[0] if next_cmd.parameters && next_cmd.parameters.length > 0
            echoln("      DEBUG: Found When for choice #{current_choice_index}")
            i += 1
          elsif next_cmd.code == 404  # End Branch - closes the choice structure
            echoln("DEBUG: Found End Branch (404), outputting #{num_choices} choice branches")
            # Now output all branches in order, but ONLY for branches that have content
            num_choices.times do |idx|
              # Skip empty branches - RMXP can't handle empty When branches
              next if all_branches[idx].empty?
              
              # Create When command for this choice
              when_cmd = RPG::EventCommand.new(402, 0, [idx, choices[idx]])
              result << when_cmd
              echoln("DEBUG: Output When branch #{idx} with #{all_branches[idx].length} commands")
              
              # Add all commands for this branch with proper indent
              all_branches[idx].each do |bc|
                bc.indent = 1 unless bc.indent > 1
                result << bc
              end
              
              # CRITICAL: Add empty command at end of each branch
              result << RPG::EventCommand.new(0, 1, [])
            end
            
            result << next_cmd  # Add the End Branch
            i += 1
            break
          elsif next_cmd.code == 411 || next_cmd.code == 412  # Else or Branch End from nested conditionals
            # Skip these - they're from incorrectly nested CONDITIONAL: ELSE statements
            # When inside a choice block, ELSE should not create command 411
            echoln("      DEBUG: Skipping command #{next_cmd.code} (Else/Branch End within choice)")
            i += 1
          elsif next_cmd.code == 0 || next_cmd.code == 102  # End of list or new choice
            # No explicit End Branch found, create all branches and add End Branch
            echoln("DEBUG: Hit code #{next_cmd.code}, outputting branches...")
            # But ONLY for branches that have content
            num_choices.times do |idx|
              # Skip empty branches - RMXP can't handle empty When branches
              if all_branches[idx].empty?
                echoln("DEBUG: Branch #{idx} is empty, skipping")
                next
              end
              
              when_cmd = RPG::EventCommand.new(402, 0, [idx, choices[idx]])
              result << when_cmd
              echoln("DEBUG: Output When branch #{idx} with #{all_branches[idx].length} commands")
              
              all_branches[idx].each do |bc|
                bc.indent = 1 unless bc.indent > 1
                result << bc
              end
              
              # CRITICAL: Add empty command at end of each branch
              result << RPG::EventCommand.new(0, 1, [])
            end
            
            result << RPG::EventCommand.new(404, 0, [])  # Add missing End Branch
            break
          else
            # Regular command inside a branch
            if current_choice_index && current_choice_index >= 0 && current_choice_index < num_choices
              all_branches[current_choice_index] << next_cmd
              echoln("      DEBUG: Added command #{next_cmd.code} to branch #{current_choice_index}")
            else
              echoln("      DEBUG: Command #{next_cmd.code} NOT added - current_choice_index=#{current_choice_index.inspect}")
            end
            i += 1
          end
        end
        
        # CRITICAL FIX: If loop ended without outputting branches (reached end of commands)
        # we need to output them now!
        echoln("DEBUG: Reached end of command list, outputting branches...")
        num_choices.times do |idx|
          if all_branches[idx].empty?
            echoln("DEBUG: Branch #{idx} is empty, skipping")
            next
          end
          
          when_cmd = RPG::EventCommand.new(402, 0, [idx, choices[idx]])
          result << when_cmd
          echoln("DEBUG: Output When branch #{idx} with #{all_branches[idx].length} commands")
          
          all_branches[idx].each do |bc|
            bc.indent = 1 unless bc.indent > 1
            result << bc
          end
          
          # CRITICAL: Add empty command at end of each branch
          result << RPG::EventCommand.new(0, 1, [])
        end
        
        result << RPG::EventCommand.new(404, 0, [])  # Add End Branch
        
      else
        # Not a choice command, just add it
        result << cmd
        i += 1
      end
    end
    
    echoln("DEBUG: fix_choice_branches complete - #{result.length} commands")
    result.compact!  # Remove any nil commands
    echoln("DEBUG: After compact - #{result.length} commands")
    return result
  end
  
  # Fix conditional branch structure: proper indents, code 0 before ELSE/End
  # This is CRITICAL for RMXP to correctly interpret IF-ELSE structures
  def self.fix_conditional_structure(commands)
    echoln("DEBUG: fix_conditional_structure - Processing #{commands.length} commands")
    result = []
    indent_stack = [0]  # Track current indent level
    
    i = 0
    while i < commands.length
      cmd = commands[i]
      
      # Safety check: skip nil commands
      if cmd.nil?
        echoln("WARNING: Encountered nil command at index #{i}, skipping")
        i += 1
        next
      end
      
      # ULTRA-CRITICAL: Ensure indent_stack never becomes empty
      if indent_stack.empty?
        echoln("ERROR: indent_stack is empty! Resetting to [0]")
        indent_stack = [0]
      end
      
      case cmd.code
      when 111  # Conditional Branch (IF)
        current_indent = indent_stack.last || 0  # Safety: default to 0
        cmd.indent = current_indent
        result << cmd
        indent_stack.push(current_indent + 1)  # Increase indent for IF content
        echoln("DEBUG: IF command (111) at indent #{current_indent}, pushed indent #{current_indent + 1}")
        i += 1
        
      when 411  # ELSE
        # CRITICAL: ELSE must be at same indent as the IF (not IF content!)
        if indent_stack.length > 1
          indent_stack.pop  # Exit IF content level
        else
          echoln("WARNING: indent_stack too shallow for ELSE, keeping at base level")
        end
        current_indent = indent_stack.last || 0  # Safety: default to 0
        
        # Insert empty command (code 0) before ELSE at IF content indent
        result << RPG::EventCommand.new(0, current_indent + 1, [])
        
        # ELSE at same level as IF
        cmd.indent = current_indent
        result << cmd
        
        # Re-enter indent for ELSE content
        indent_stack.push(current_indent + 1)
        echoln("DEBUG: ELSE command (411) at indent #{current_indent}, pushed indent #{current_indent + 1}")
        i += 1
        
      when 412  # Branch End
        # CRITICAL: Branch End must be at same indent as the IF
        if indent_stack.length > 1
          indent_stack.pop  # Exit current branch content level
        else
          echoln("WARNING: indent_stack too shallow for Branch End, keeping at base level")
        end
        current_indent = indent_stack.last || 0  # Safety: default to 0
        
        # Insert empty command (code 0) before Branch End at branch content indent
        result << RPG::EventCommand.new(0, current_indent + 1, [])
        
        # Branch End at same level as IF
        cmd.indent = current_indent
        result << cmd
        echoln("DEBUG: Branch End (412) at indent #{current_indent}")
        i += 1
        
      when 0  # Empty command - might already be there, don't duplicate
        # Check if we just added a code 0
        if result.last && result.last.code == 0
          # Skip this one, we already added it
          i += 1
        else
          current_indent = indent_stack.last || 0  # Safety: default to 0
          cmd.indent = current_indent
          result << cmd
          i += 1
        end
        
      else  # Regular command
        current_indent = indent_stack.last || 0  # Safety: default to 0
        cmd.indent = current_indent
        result << cmd
        i += 1
      end
    end
    
    # ULTRA-CRITICAL: Close ALL open IF blocks
    # indent_stack should be [0] at this point, but if there are unclosed IFs, close them
    while indent_stack.length > 1
      indent_stack.pop  # Exit the IF content level
      current_indent = indent_stack.last || 0
      
      # Add code 0 before branch end
      result << RPG::EventCommand.new(0, current_indent + 1, [])
      
      # Add Branch End (412) at the same level as the IF
      result << RPG::EventCommand.new(412, current_indent, [])
      echoln("DEBUG: Auto-closing IF block - added Branch End (412) at indent #{current_indent}")
    end
    
    echoln("DEBUG: fix_conditional_structure complete - #{result.length} commands")
    result.compact!  # Remove any nil commands
    echoln("DEBUG: After compact - #{result.length} commands")
    return result
  end
  
  # Helper methods for creating commands
  def self.create_text_command(text)
    # Command 101: Show Text
    RPG::EventCommand.new(101, 0, [text])
  end
  
  def self.create_script_command(script)
    # Command 355: Script
    RPG::EventCommand.new(355, 0, [script])
  end
  
  def self.create_switch_command(switch_id, value)
    # Command 121: Control Switches
    RPG::EventCommand.new(121, 0, [switch_id, switch_id, value ? 0 : 1])
  end
  
  def self.create_self_switch_command(self_switch, value)
    # Command 123: Control Self Switch
    RPG::EventCommand.new(123, 0, [self_switch, value ? 0 : 1])
  end
  
  def self.parse_variable(var_id, operation_str)
    # Command 122: Control Variables
    # Format: var_id, operation (=, +, -, *, /, %), value
    if operation_str =~ /^\s*=\s*(.+)/
      value = parse_value($1.strip)
      return RPG::EventCommand.new(122, 0, [var_id, var_id, 0, 0, value])
    elsif operation_str =~ /^\s*\+\s*(.+)/
      value = parse_value($1.strip)
      return RPG::EventCommand.new(122, 0, [var_id, var_id, 1, 0, value])
    elsif operation_str =~ /^\s*-\s*(.+)/
      value = parse_value($1.strip)
      return RPG::EventCommand.new(122, 0, [var_id, var_id, 2, 0, value])
    else
      value = parse_value(operation_str)
      return RPG::EventCommand.new(122, 0, [var_id, var_id, 0, 0, value])
    end
  end
  
  def self.parse_value(value_str)
    # Parse numeric values or variable references
    if value_str =~ /^VAR\[(\d+)\]$/i
      return $1.to_i  # Variable reference
    else
      return value_str.to_i
    end
  end
  
  def self.create_item_command(item_symbol, quantity)
    # Command 355: Script with pbReceiveItem
    script = "pbReceiveItem(:#{item_symbol}, #{quantity})"
    RPG::EventCommand.new(355, 0, [script])
  end
  
  def self.create_pokemon_command(species_symbol, level)
    # Command 355: Script with pbAddPokemon
    script = "pbAddPokemon(:#{species_symbol}, #{level})"
    RPG::EventCommand.new(355, 0, [script])
  end
  
  def self.create_choice_command(choices)
    # Command 102: Show Choices
    # Parameters: [choices_array, cancel_type]
    RPG::EventCommand.new(102, 0, [choices, 0])
  end
  
  def self.parse_conditional(condition_str, context = {})
    # Command 111: Conditional Branch OR Command 402: When (for choices)
    echoln("DEBUG: parse_conditional - #{condition_str}")
    if condition_str =~ /CHOICE\s*==\s*(\d+)/i
      # When [Choice X] - command 402
      # Convert from 1-based (user-friendly) to 0-based (RMXP internal)
      # User writes CHOICE == 1, RMXP uses index 0
      choice_index = $1.to_i - 1
      echoln("DEBUG: Created CHOICE conditional - index #{choice_index}")
      # Store choice index in parameters[0], indent stays 0
      # Will be properly indented by fix_choice_branches
      return RPG::EventCommand.new(402, 0, [choice_index])
    elsif condition_str =~ /SELF_SWITCH\s*([A-D])\s*==\s*(ON|OFF)/i
      # Self Switch conditional - command 111, type 2 (NOT type 10!)
      # CRITICAL: RMXP uses type 2 for Self Switch conditionals
      self_switch_ch = $1.upcase
      value = ($2.upcase == "ON") ? 0 : 1
      echoln("DEBUG: Created SELF_SWITCH conditional - #{self_switch_ch} == #{value == 0 ? 'ON' : 'OFF'}")
      return RPG::EventCommand.new(111, 0, [2, self_switch_ch, value])
    elsif condition_str =~ /SWITCH\s*(\d+)\s*==\s*(ON|OFF)/i
      switch_id = $1.to_i
      value = ($2.upcase == "ON") ? 0 : 1
      echoln("DEBUG: Created SWITCH conditional - #{switch_id} == #{value == 0 ? 'ON' : 'OFF'}")
      return RPG::EventCommand.new(111, 0, [0, switch_id, value])
    elsif condition_str =~ /SWITCH\s*(\d+)/i
      switch_id = $1.to_i
      echoln("DEBUG: Created SWITCH conditional - #{switch_id}")
      return RPG::EventCommand.new(111, 0, [0, switch_id, 0])
    elsif condition_str =~ /VARIABLE\s*(\d+)\s*(>=|<=|==|>|<)\s*(\d+)/i
      var_id = $1.to_i
      # CRITICAL: RMXP operators: 0==, 1>=, 2<=, 3>, 4<, 5!=
      operator = case $2
        when "==" then 0
        when ">=" then 1
        when "<=" then 2
        when ">" then 3
        when "<" then 4
        else 0
      end
      value = $3.to_i
      echoln("DEBUG: Created VARIABLE conditional - var#{var_id} #{$2} #{value}")
      return RPG::EventCommand.new(111, 0, [1, var_id, operator, value])
    elsif condition_str =~ /ELSE/i
      # Check context to see if we're in a choice branch
      if context[:in_choice_branch]
        # When [Next Choice] - command 402
        next_choice = context[:current_choice_index] + 1
        echoln("DEBUG: Created ELSE (next choice) - index #{next_choice}")
        return RPG::EventCommand.new(402, next_choice, [])
      else
        # Else branch - command 411
        echoln("DEBUG: Created ELSE conditional (411)")
        return RPG::EventCommand.new(411, 0, [])
      end
    end
    # Default: always true
    echoln("DEBUG: Created default conditional (always true)")
    return RPG::EventCommand.new(111, 0, [0, 0, 0])
  end
  
  def self.create_wait_command(frames)
    # Command 106: Wait
    RPG::EventCommand.new(106, 0, [frames])
  end
  
  def self.create_play_se_command(se_name)
    # Command 250: Play SE
    audio = RPG::AudioFile.new(se_name, 100, 100)
    RPG::EventCommand.new(250, 0, [audio])
  end
  
  def self.create_play_bgm_command(bgm_name)
    # Command 241: Play BGM
    audio = RPG::AudioFile.new(bgm_name, 100, 100)
    RPG::EventCommand.new(241, 0, [audio])
  end
  
  def self.create_play_me_command(me_name)
    # Command 249: Play ME
    audio = RPG::AudioFile.new(me_name, 100, 100)
    RPG::EventCommand.new(249, 0, [audio])
  end
  
  def self.create_show_picture_command(pic_num, pic_name, x, y)
    # Command 231: Show Picture
    # Parameters: [pic_num, pic_name, origin(0=UL,1=Center), appointment_method(0=direct,1=vars), x, y, zoom_x, zoom_y, opacity, blend_type]
    RPG::EventCommand.new(231, 0, [pic_num, pic_name, 0, 0, x, y, 100, 100, 255, 0])
  end
  
  def self.create_move_picture_command(pic_num, x, y)
    # Command 232: Move Picture
    # Parameters: [pic_num, duration, origin, appointment_method(0=direct,1=vars), x, y, zoom_x, zoom_y, opacity, blend_type]
    RPG::EventCommand.new(232, 0, [pic_num, 20, 0, 0, x, y, 100, 100, 255, 0])
  end
  
  def self.parse_transfer(transfer_str)
    # Format: MAP_ID, X, Y, [Direction]
    echoln("DEBUG: parse_transfer - #{transfer_str}")
    if transfer_str =~ /(\d+)\s*,\s*(\d+)\s*,\s*(\d+)(?:\s*,\s*(\w+))?/
      map_id = $1.to_i
      x = $2.to_i
      y = $3.to_i
      direction = parse_direction($4 || "Down")
      echoln("DEBUG: Created TRANSFER command - map #{map_id} to (#{x}, #{y})")
      # Command 201: Transfer Player
      # Parameters: [constant(0), map_id, x, y, direction, fade_type(0=black,1=white,2=none)]
      return RPG::EventCommand.new(201, 0, [0, map_id, x, y, direction, 0])
    end
    return RPG::EventCommand.new(0, 0, [])
  end
  
  def self.parse_move_route(route_str)
    # Format: PLAYER or EVENT_ID, commands...
    # For now, simple version: SET_MOVE_ROUTE: PLAYER, THROUGH_ON, TURN_RIGHT, MOVE_UP
    echoln("DEBUG: parse_move_route - #{route_str}")
    target = 0  # 0 = this event, -1 = player
    commands_list = []
    
    parts = route_str.split(',').map(&:strip)
    if parts[0].upcase == "PLAYER"
      target = -1
      parts.shift
      echoln("DEBUG: Move route target = PLAYER")
    elsif parts[0] =~ /^\d+$/
      target = parts[0].to_i
      parts.shift
      echoln("DEBUG: Move route target = EVENT #{target}")
    end
    
    # Parse move commands - each MoveCommand needs code and parameters array
    # Codes from Event Exporter script.rb lines 1206-1315
    parts.each do |cmd|
      case cmd.upcase
      when "MOVE_DOWN" then commands_list << RPG::MoveCommand.new(1, [])
      when "MOVE_LEFT" then commands_list << RPG::MoveCommand.new(2, [])
      when "MOVE_RIGHT" then commands_list << RPG::MoveCommand.new(3, [])
      when "MOVE_UP" then commands_list << RPG::MoveCommand.new(4, [])
      when "MOVE_LOWER_LEFT" then commands_list << RPG::MoveCommand.new(5, [])
      when "MOVE_LOWER_RIGHT" then commands_list << RPG::MoveCommand.new(6, [])
      when "MOVE_UPPER_LEFT" then commands_list << RPG::MoveCommand.new(7, [])
      when "MOVE_UPPER_RIGHT" then commands_list << RPG::MoveCommand.new(8, [])
      when "MOVE_RANDOM" then commands_list << RPG::MoveCommand.new(9, [])
      when "MOVE_TOWARD_PLAYER" then commands_list << RPG::MoveCommand.new(10, [])
      when "MOVE_AWAY_FROM_PLAYER" then commands_list << RPG::MoveCommand.new(11, [])
      when "STEP_FORWARD" then commands_list << RPG::MoveCommand.new(12, [])
      when "STEP_BACKWARD" then commands_list << RPG::MoveCommand.new(13, [])
      when "TURN_DOWN" then commands_list << RPG::MoveCommand.new(16, [])
      when "TURN_LEFT" then commands_list << RPG::MoveCommand.new(17, [])
      when "TURN_RIGHT" then commands_list << RPG::MoveCommand.new(18, [])
      when "TURN_UP" then commands_list << RPG::MoveCommand.new(19, [])
      when "TURN_90_RIGHT" then commands_list << RPG::MoveCommand.new(20, [])
      when "TURN_90_LEFT" then commands_list << RPG::MoveCommand.new(21, [])
      when "TURN_180" then commands_list << RPG::MoveCommand.new(22, [])
      when "TURN_90_RIGHT_OR_LEFT" then commands_list << RPG::MoveCommand.new(23, [])
      when "TURN_RANDOM" then commands_list << RPG::MoveCommand.new(24, [])
      when "TURN_TOWARD_PLAYER" then commands_list << RPG::MoveCommand.new(25, [])
      when "TURN_AWAY_FROM_PLAYER" then commands_list << RPG::MoveCommand.new(26, [])
      when "MOVE_ANIMATION_ON" then commands_list << RPG::MoveCommand.new(31, [])
      when "MOVE_ANIMATION_OFF" then commands_list << RPG::MoveCommand.new(32, [])
      when "STOP_ANIMATION_ON" then commands_list << RPG::MoveCommand.new(33, [])
      when "STOP_ANIMATION_OFF" then commands_list << RPG::MoveCommand.new(34, [])
      when "DIRECTION_FIX_ON" then commands_list << RPG::MoveCommand.new(35, [])
      when "DIRECTION_FIX_OFF" then commands_list << RPG::MoveCommand.new(36, [])
      when "THROUGH_ON" then commands_list << RPG::MoveCommand.new(37, [])
      when "THROUGH_OFF" then commands_list << RPG::MoveCommand.new(38, [])
      when "ALWAYS_ON_TOP_ON" then commands_list << RPG::MoveCommand.new(39, [])
      when "ALWAYS_ON_TOP_OFF" then commands_list << RPG::MoveCommand.new(40, [])
      end
    end
    
    commands_list << RPG::MoveCommand.new(0, [])  # End of move route
    
    move_route = RPG::MoveRoute.new
    move_route.repeat = false
    move_route.skippable = false
    move_route.list = commands_list
    
    # Command 209: Set Move Route
    return RPG::EventCommand.new(209, 0, [target, move_route])
  end
  
  def self.parse_screen_tone(tone_str)
    # Format: R, G, B, GRAY, DURATION
    # Example: -255, -255, -255, 0, 6
    if tone_str =~ /([+-]?\d+)\s*,\s*([+-]?\d+)\s*,\s*([+-]?\d+)\s*,\s*([+-]?\d+)(?:\s*,\s*(\d+))?/
      r = $1.to_i
      g = $2.to_i
      b = $3.to_i
      gray = $4.to_i
      duration = $5 ? $5.to_i : 6
      
      tone = Tone.new(r, g, b, gray)
      # Command 223: Change Screen Color Tone
      return RPG::EventCommand.new(223, 0, [tone, duration])
    end
    return RPG::EventCommand.new(0, 0, [])
  end
  
  def self.parse_trigger(trigger_str)
    case trigger_str.upcase
    when "ACTION", "ACTION_BUTTON" then 0
    when "PLAYER_TOUCH", "TOUCH" then 1
    when "EVENT_TOUCH" then 2
    when "AUTORUN" then 3
    when "PARALLEL" then 4
    else 0
    end
  end
  
  def self.parse_move_type(type_str)
    case type_str.upcase
    when "FIXED" then 0
    when "RANDOM" then 1
    when "APPROACH" then 2
    when "CUSTOM" then 3
    else 0
    end
  end
  
  def self.parse_direction(dir_str)
    case dir_str.upcase
    when "DOWN" then 2
    when "LEFT" then 4
    when "RIGHT" then 6
    when "UP" then 8
    else 2
    end
  end
  
  # Load a map file
  def self.load_map(map_id)
    map_file = sprintf("Data/Map%03d.rxdata", map_id)
    if FileTest.exist?(map_file)
      return load_data(map_file)
    else
      echoln("WARNING: Map #{map_id} does not exist! Creating from template...")
      # Try to create from a template map (Map002 is usually a good outdoor map)
      template_map = nil
      [2, 3, 1].each do |template_id|
        template_file = sprintf("Data/Map%03d.rxdata", template_id)
        if FileTest.exist?(template_file)
          template_map = load_data(template_file)
          echoln("  Using Map #{template_id} as template")
          break
        end
      end
      
      if template_map
        # Clear all events from template
        template_map.events.clear
        echoln("  Cleared template events, creating empty Map #{map_id}")
        # Save the new empty map
        save_map(map_id, template_map)
        return template_map
      else
        echoln("ERROR: No template map found to create Map #{map_id}!")
        return nil
      end
    end
  end
  
  # Add or update event on map
  def self.add_event_to_map(map, event)
    # Check if an event with the same name and position already exists
    existing_event = nil
    existing_id = nil
    
    map.events.each do |id, existing|
      if existing.name == event.name && existing.x == event.x && existing.y == event.y
        existing_event = existing
        existing_id = id
        break
      end
    end
    
    if existing_event
      # Event exists at this position with this name - update it
      echoln("    Updating existing event ID #{existing_id}")
      event.id = existing_id
      map.events[existing_id] = event
    else
      # New event - find next available ID
      max_id = 0
      map.events.each_key { |id| max_id = id if id > max_id }
      event.id = max_id + 1
      map.events[event.id] = event
    end
  end
  
  # Ensure map is large enough for all events
  def self.ensure_map_size(map)
    return if map.events.empty?
    
    # Find maximum event coordinates
    max_x = 0
    max_y = 0
    map.events.each do |id, event|
      next if event.nil?
      max_x = event.x if event.x > max_x
      max_y = event.y if event.y > max_y
    end
    
    # Add padding
    required_width = max_x + 5
    required_height = max_y + 5
    
    # Check if map needs to be resized
    if map.width < required_width || map.height < required_height
      old_width = map.width
      old_height = map.height
      
      new_width = [map.width, required_width].max
      new_height = [map.height, required_height].max
      
      echoln("  Resizing map from #{old_width}x#{old_height} to #{new_width}x#{new_height}")
      
      # Resize map data arrays
      map.width = new_width
      map.height = new_height
      
      # Resize data layers (3 layers in RMXP)
      3.times do |z|
        old_data = map.data
        new_data = Table.new(new_width, new_height, 3)
        
        # Copy old data to new table
        (0...old_width).each do |x|
          (0...old_height).each do |y|
            (0...3).each do |layer|
              new_data[x, y, layer] = old_data[x, y, layer]
            end
          end
        end
        
        map.data = new_data
      end
      
      echoln("  Map resized successfully!")
    end
  end
  
  # Save map file
  def self.save_map(map_id, map)
    # Ensure map is big enough for all events
    ensure_map_size(map)
    
    map_file = sprintf("Data/Map%03d.rxdata", map_id)
    File.open(map_file, "wb") { |f| Marshal.dump(map, f) }
    echoln("Saved Map #{map_id} with imported events")
  end
  
  # Delete all save files to prevent loading old map data
  def self.delete_save_files
    deleted_count = 0
    Dir.glob("*.rxdata").each do |file|
      if file =~ /Save\d+\.rxdata/i
        File.delete(file)
        deleted_count += 1
      end
    end
    echoln("Deleted #{deleted_count} save file(s)")
  end

  # Get list of available map files
  def self.get_available_maps
    maps = []
    Dir.glob("Data/Map*.rxdata").each do |file|
      if file =~ /Map(\d+)\.rxdata/
        map_id = $1.to_i
        map_name = pbGetMapNameFromId(map_id) rescue "Map #{map_id}"
        maps << [map_id, map_name]
      end
    end
    maps.sort_by { |m| m[0] }
  end

  # Get list of maps with import files
  def self.get_maps_with_import_files
    maps = []
    Dir.glob("EventImporter/map*.txt").each do |file|
      if file =~ /map(\d+)[_\w]*\.txt$/i
        map_id = $1.to_i
        map_name = pbGetMapNameFromId(map_id) rescue "Map #{map_id}"
        maps << [map_id, map_name] unless maps.any? { |m| m[0] == map_id }
      end
    end
    maps.sort_by { |m| m[0] }
  end
end

# Debug menu option - Import Events with Map Selection
MenuHandlers.add(:debug_menu, :import_events, {
  "name"        => _INTL("Import Events"),
  "parent"      => :main,
  "description" => _INTL("Import events from text files in EventImporter folder."),
  "effect"      => proc { |menu|
    # Get list of maps with import files
    maps = EventImporter.get_maps_with_import_files
    
    if maps.empty?
      pbMessage(_INTL("No map import files found in EventImporter folder."))
      next
    end
    
    # Create choice list
    commands = []
    maps.each do |map_id, map_name|
      commands << _INTL("Map {1}: {2}", map_id, map_name)
    end
    commands << _INTL("Import ALL maps")
    commands << _INTL("Cancel")
    
    # Show selection
    choice = pbMessage(_INTL("Select which map to import:"), commands, -1)
    
    if choice >= 0 && choice < maps.length
      # Import single map
      map_id = maps[choice][0]
      pbMessage(_INTL("Importing Map {1}...", map_id))
      count = EventImporter.import_events_for_map(map_id)
      
      if count && count > 0
        pbMessage(_INTL("Successfully imported {1} event(s) for Map {2}!", count, map_id))
        # Reload map if it's the current one
        if $game_map && $game_map.map_id == map_id
          $game_map.setup($game_map.map_id)
          $scene.disposeSpritesets if $scene.respond_to?(:disposeSpritesets)
          $scene.createSpritesets if $scene.respond_to?(:createSpritesets)
        end
      elsif count == 0
        pbMessage(_INTL("No events found in Map {1} import files.", map_id))
      else
        pbMessage(_INTL("Import failed for Map {1}. Check console.", map_id))
      end
      
    elsif choice == maps.length
      # Import all maps
      pbMessage(_INTL("Importing all maps..."))
      count = EventImporter.import_all_events
      
      if count && count > 0
        pbMessage(_INTL("Successfully imported {1} event(s) from all maps!", count))
        # Reload current map
        if $game_map
          $game_map.setup($game_map.map_id)
          $scene.disposeSpritesets if $scene.respond_to?(:disposeSpritesets)
          $scene.createSpritesets if $scene.respond_to?(:createSpritesets)
        end
      elsif count == 0
        pbMessage(_INTL("No events to import."))
      else
        pbMessage(_INTL("Import failed. Check console."))
      end
    end
  }
})

# Debug menu option - Delete Map Events
MenuHandlers.add(:debug_menu, :delete_map_events, {
  "name"        => _INTL("Delete Map Events"),
  "parent"      => :main,
  "description" => _INTL("Delete all events from a specific map."),
  "effect"      => proc { |menu|
    # Get list of all available maps
    maps = EventImporter.get_available_maps
    
    if maps.empty?
      pbMessage(_INTL("No maps found."))
      next
    end
    
    # Create choice list
    commands = []
    maps.each do |map_id, map_name|
      commands << _INTL("Map {1}: {2}", map_id, map_name)
    end
    commands << _INTL("Cancel")
    
    # Show selection
    choice = pbMessage(_INTL("Select which map to clear:"), commands, -1)
    
    if choice >= 0 && choice < maps.length
      map_id = maps[choice][0]
      map_name = maps[choice][1]
      
      # Confirm deletion
      if pbConfirmMessage(_INTL("Delete ALL events from Map {1}: {2}?\nThis cannot be undone!", map_id, map_name))
        begin
          map_file = sprintf("Data/Map%03d.rxdata", map_id)
          map = load_data(map_file)
          
          event_count = map.events.size
          map.events.clear
          
          File.open(map_file, "wb") { |f| Marshal.dump(map, f) }
          
          pbMessage(_INTL("Deleted {1} event(s) from Map {2}.", event_count, map_id))
          
          # Reload map if it's the current one
          if $game_map && $game_map.map_id == map_id
            $game_map.setup($game_map.map_id)
            $scene.disposeSpritesets if $scene.respond_to?(:disposeSpritesets)
            $scene.createSpritesets if $scene.respond_to?(:createSpritesets)
          end
        rescue => e
          pbMessage(_INTL("Error deleting events: {1}", e.message))
          puts "Delete events error: #{e.message}"
          puts e.backtrace
        end
      end
    end
  }
})

# Auto-import on game startup (DISABLED - use F9 Debug Menu instead)
# EventImporter.import_all_events

# Hook into map loading to ensure imported events are always present
EventHandlers.add(:on_map_or_spriteset_change, :import_events_on_load,
  proc { |_scene, _map_changed|
    # Check if current map has import files
    map_id = $game_map.map_id
    folder = "EventImporter"
    return unless FileTest.directory?(folder)
    
    # Find files for this map
    patterns = [
      File.join(folder, "map#{map_id}*.txt"),
      File.join(folder, "map#{sprintf('%03d', map_id)}*.txt")
    ]
    
    files = []
    patterns.each do |pattern|
      files += Dir.glob(pattern, File::FNM_CASEFOLD)
    end
    files.uniq!
    files.reject! { |f| File.basename(f).start_with?('_') }
    
    # If this map has import files, check if events need to be re-imported
    if files.length > 0
      # Load the actual map file to see how many events it should have
      map_file = sprintf("Data/Map%03d.rxdata", map_id)
      if FileTest.exist?(map_file)
        saved_map = load_data(map_file)
        
        # Compare event count - if current map has fewer events, reload from file
        if $game_map.events.size < saved_map.events.size
          # Events are missing! Reload the map from file
          $game_map.setup(map_id)
          $scene.disposeSpritesets if $scene.respond_to?(:disposeSpritesets)
          $scene.createSpritesets if $scene.respond_to?(:createSpritesets)
        end
      end
    end
  }
)

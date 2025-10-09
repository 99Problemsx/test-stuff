#===============================================================================
# Time-Based Fishing Encounters - Debug Menu Utilities
#===============================================================================
# Adds debug menu options for testing time-based fishing encounters
#===============================================================================

MenuHandlers.add(:debug_menu, :test_time_fishing, {
  "name"        => _INTL("Test time-based fishing"),
  "parent"      => :battle_menu,
  "description" => _INTL("Test fishing encounters at different times of day."),
  "effect"      => proc {
    # Check if player can fish here
    notCliff = $game_map.passable?($game_player.x, $game_player.y, $game_player.direction, $game_player)
    if !$game_player.pbFacingTerrainTag.can_fish || (!$PokemonGlobal.surfing && !notCliff)
      pbMessage(_INTL("You need to face water to test fishing encounters."))
      next false
    end
    
    # Choose rod type
    rod_commands = [
      _INTL("Old Rod"),
      _INTL("Good Rod"),
      _INTL("Super Rod")
    ]
    rod_types = [:OldRod, :GoodRod, :SuperRod]
    rod_choice = pbShowCommands(nil, rod_commands, -1)
    next false if rod_choice < 0
    
    base_type = rod_types[rod_choice]
    
    # Show available encounter types for this location
    time_variants = []
    time_names = []
    
    # Check all time variants
    [
      [:Morning, "Morning"],
      [:Afternoon, "Afternoon"],
      [:Evening, "Evening"],
      [:Day, "Day"],
      [:Night, "Night"],
      [nil, "Base (no time)"]
    ].each do |suffix, name|
      if suffix
        enc_type = (base_type.to_s + suffix.to_s).to_sym
      else
        enc_type = base_type
      end
      
      if $PokemonEncounters.has_encounter_type?(enc_type)
        time_variants.push(enc_type)
        time_names.push(_INTL("{1} ({2})", name, enc_type.to_s))
      end
    end
    
    if time_variants.empty?
      pbMessage(_INTL("No fishing encounters are defined for this map."))
      next false
    end
    
    # Let user choose which variant to test
    time_choice = pbShowCommands(nil, time_names + [_INTL("Cancel")], -1)
    next false if time_choice < 0 || time_choice >= time_variants.length
    
    chosen_type = time_variants[time_choice]
    
    # Show what would be encountered
    enc_data = $PokemonEncounters.encounter_data
    if enc_data && enc_data.types[chosen_type]
      message = _INTL("Encounter type: {1}\\n", chosen_type.to_s)
      message += _INTL("Current time: {1}\\n", pbGetTimeNow.strftime("%H:%M"))
      message += _INTL("Is Day: {1}, Is Night: {2}\\n", 
                       PBDayNight.isDay?, PBDayNight.isNight?)
      message += _INTL("\\nPossible encounters:\\n")
      
      enc_data.types[chosen_type].each do |slot|
        species_name = GameData::Species.get(slot[0]).name
        message += _INTL("- {1} (Lv.{2}", species_name, slot[1])
        message += _INTL("-{1}", slot[2]) if slot[2] != slot[1]
        message += ")\n"
      end
      
      pbMessage(message)
      
      # Option to start encounter
      if pbConfirmMessage(_INTL("Start a test encounter?"))
        # Trigger actual encounter
        encounter = $PokemonEncounters.has_encounter_type?(chosen_type)
        if pbFishing(encounter, rod_choice + 1)
          pbEncounter(chosen_type)
        end
      end
    else
      pbMessage(_INTL("Error: Encounter data not found."))
    end
    
    next false
  }
})

MenuHandlers.add(:debug_menu, :show_current_fishing_type, {
  "name"        => _INTL("Show current fishing encounter type"),
  "parent"      => :battle_menu,
  "description" => _INTL("Shows which fishing encounter type would be used right now."),
  "effect"      => proc {
    time = pbGetTimeNow
    
    message = _INTL("Current Time: {1}\\n", time.strftime("%H:%M"))
    message += _INTL("Is Day: {1}\\n", PBDayNight.isDay?(time))
    message += _INTL("Is Night: {1}\\n", PBDayNight.isNight?(time))
    message += _INTL("Is Morning: {1}\\n", PBDayNight.isMorning?(time))
    message += _INTL("Is Afternoon: {1}\\n", PBDayNight.isAfternoon?(time))
    message += _INTL("Is Evening: {1}\\n", PBDayNight.isEvening?(time))
    message += "\\n"
    
    # Show what would be used for each rod
    [:OldRod, :GoodRod, :SuperRod].each do |base_type|
      enc_type = $PokemonEncounters.find_valid_encounter_type_for_fishing_time(base_type)
      message += _INTL("{1} would use:\\n  {2}\\n", base_type.to_s, enc_type.to_s)
    end
    
    pbMessage(message)
    next false
  }
})

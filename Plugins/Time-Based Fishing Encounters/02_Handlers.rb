#===============================================================================
# Time-Based Fishing Encounters - Rod Item Handlers
#===============================================================================
# This overrides the default fishing rod handlers to check for time-based
# encounter types before falling back to the standard ones.
#===============================================================================

class PokemonEncounters
  # Finds the appropriate encounter type for the current time of day
  # Checks in this order:
  # 1. Specific time (Morning/Afternoon/Evening)
  # 2. General day/night (Day/Night)
  # 3. Base type (OldRod/GoodRod/SuperRod)
  def find_valid_encounter_type_for_fishing_time(base_type)
    ret = nil
    time = pbGetTimeNow
    
    # Check for specific time-of-day variants first
    if PBDayNight.isDay?(time)
      try_type = nil
      if PBDayNight.isMorning?(time)
        try_type = (base_type.to_s + "Morning").to_sym
      elsif PBDayNight.isAfternoon?(time)
        try_type = (base_type.to_s + "Afternoon").to_sym
      elsif PBDayNight.isEvening?(time)
        try_type = (base_type.to_s + "Evening").to_sym
      end
      ret = try_type if try_type && has_encounter_type?(try_type)
      
      # If no specific time found, try general "Day" variant
      if !ret
        try_type = (base_type.to_s + "Day").to_sym
        ret = try_type if has_encounter_type?(try_type)
      end
    else
      # It's night time
      try_type = (base_type.to_s + "Night").to_sym
      ret = try_type if has_encounter_type?(try_type)
    end
    
    # Fall back to base type if no time-specific type found
    return ret if ret
    return has_encounter_type?(base_type) ? base_type : nil
  end
end

#===============================================================================
# Rod Item Handlers
#===============================================================================

ItemHandlers::UseInField.add(:OLDROD, proc { |item|
  notCliff = $game_map.passable?($game_player.x, $game_player.y, $game_player.direction, $game_player)
  if !$game_player.pbFacingTerrainTag.can_fish || (!$PokemonGlobal.surfing && !notCliff)
    pbMessage(_INTL("Can't use that here."))
    next false
  end
  # Find the appropriate encounter type for the current time
  enctype = $PokemonEncounters.find_valid_encounter_type_for_fishing_time(:OldRod)
  encounter = $PokemonEncounters.has_encounter_type?(enctype)
  if pbFishing(encounter, 1)
    $stats.fishing_battles += 1
    pbEncounter(enctype)
  end
  next true
})

ItemHandlers::UseInField.add(:GOODROD, proc { |item|
  notCliff = $game_map.passable?($game_player.x, $game_player.y, $game_player.direction, $game_player)
  if !$game_player.pbFacingTerrainTag.can_fish || (!$PokemonGlobal.surfing && !notCliff)
    pbMessage(_INTL("Can't use that here."))
    next false
  end
  # Find the appropriate encounter type for the current time
  enctype = $PokemonEncounters.find_valid_encounter_type_for_fishing_time(:GoodRod)
  encounter = $PokemonEncounters.has_encounter_type?(enctype)
  if pbFishing(encounter, 2)
    $stats.fishing_battles += 1
    pbEncounter(enctype)
  end
  next true
})

ItemHandlers::UseInField.add(:SUPERROD, proc { |item|
  notCliff = $game_map.passable?($game_player.x, $game_player.y, $game_player.direction, $game_player)
  if !$game_player.pbFacingTerrainTag.can_fish || (!$PokemonGlobal.surfing && !notCliff)
    pbMessage(_INTL("Can't use that here."))
    next false
  end
  # Find the appropriate encounter type for the current time
  enctype = $PokemonEncounters.find_valid_encounter_type_for_fishing_time(:SuperRod)
  encounter = $PokemonEncounters.has_encounter_type?(enctype)
  if pbFishing(encounter, 3)
    $stats.fishing_battles += 1
    pbEncounter(enctype)
  end
  next true
})

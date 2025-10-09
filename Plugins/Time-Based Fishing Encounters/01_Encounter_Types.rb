#===============================================================================
# Time-Based Fishing Encounters - Encounter Type Definitions
#===============================================================================
# This plugin adds day/night/time-of-day variations for fishing rod encounters
# Similar to how Land and Water encounters have LandDay, LandNight, etc.
#===============================================================================

# Day/Night variants
GameData::EncounterType.register({
  :id   => :OldRodDay,
  :type => :fishing
})

GameData::EncounterType.register({
  :id   => :OldRodNight,
  :type => :fishing
})

GameData::EncounterType.register({
  :id   => :GoodRodDay,
  :type => :fishing
})

GameData::EncounterType.register({
  :id   => :GoodRodNight,
  :type => :fishing
})

GameData::EncounterType.register({
  :id   => :SuperRodDay,
  :type => :fishing
})

GameData::EncounterType.register({
  :id   => :SuperRodNight,
  :type => :fishing
})

# Morning/Afternoon/Evening variants (more granular)
GameData::EncounterType.register({
  :id   => :OldRodMorning,
  :type => :fishing
})

GameData::EncounterType.register({
  :id   => :OldRodAfternoon,
  :type => :fishing
})

GameData::EncounterType.register({
  :id   => :OldRodEvening,
  :type => :fishing
})

GameData::EncounterType.register({
  :id   => :GoodRodMorning,
  :type => :fishing
})

GameData::EncounterType.register({
  :id   => :GoodRodAfternoon,
  :type => :fishing
})

GameData::EncounterType.register({
  :id   => :GoodRodEvening,
  :type => :fishing
})

GameData::EncounterType.register({
  :id   => :SuperRodMorning,
  :type => :fishing
})

GameData::EncounterType.register({
  :id   => :SuperRodAfternoon,
  :type => :fishing
})

GameData::EncounterType.register({
  :id   => :SuperRodEvening,
  :type => :fishing
})

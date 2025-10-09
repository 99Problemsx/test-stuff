#===============================================================================
# Fix for Raid Counters Not Resetting After Failure
#===============================================================================
# Bug: Turn count and KO count don't reset after failing a raid (decision = 3)
# Root Cause: The rules hash gets modified during battle and these modified
#             values persist when passed to the next raid
# Solution: Intercept in RaidBattle.start and clone the rules hash
#===============================================================================

#===============================================================================
# Fix: Clone rules hash before starting raid to prevent value carryover
#===============================================================================
class RaidBattle
  class << self
    alias raid_counter_fix_start start
    
    def start(pkmn = {}, rules = {})
      # Clone the rules hash to ensure fresh counter values
      # This prevents depleted counters from previous battles from persisting
      rules = rules.clone if rules.is_a?(Hash)
      
      # Call the original start method with the cloned rules
      return raid_counter_fix_start(pkmn, rules)
    end
  end
end

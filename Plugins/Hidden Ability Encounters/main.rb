#===============================================================================
# Hidden Ability Encounters - Main Script
#===============================================================================

class Pokemon
  # Override ability_index to give wild Pokémon a chance for hidden ability
  alias hidden_ability_encounters_ability_index ability_index
  
  def ability_index
    # Check if this is a wild encounter and roll for hidden ability
    if rand(100) < HiddenAbilityEncounters::HIDDEN_ABILITY_CHANCE
      # Return hidden ability index (2)
      return 2
    else
      # Use original ability calculation
      return hidden_ability_encounters_ability_index
    end
  end
end

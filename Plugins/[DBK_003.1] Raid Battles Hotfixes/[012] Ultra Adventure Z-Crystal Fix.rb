#===============================================================================
# Ultra Adventure Z-Crystal Fix
# Fixes a rare bug where Ultra Raid/Adventure Pokemon sometimes load without
# a Z-Crystal attached, causing immediate crashes.
#===============================================================================

class Pokemon
  #-----------------------------------------------------------------------------
  # Applies raid attributes to wild Pokemon.
  # Added safety checks and explicit Z-Crystal assignment for Ultra style.
  #-----------------------------------------------------------------------------
  alias zcrystal_fix_setRaidBossAttributes setRaidBossAttributes
  def setRaidBossAttributes(rules)
    return if !species_data.raid_species?(rules[:style])
    
    # Call original method
    zcrystal_fix_setRaidBossAttributes(rules)
    
    # [HOTFIX] Ensure Z-Crystal is assigned for Ultra raids if missing
    if rules[:style] == :Ultra
      # Check if Pokemon should have a Z-Crystal but doesn't
      if !self.hasZCrystal? && !self.ultra? && !self.hasItem?
        # Assign a compatible Z-Crystal
        self.item = GameData::Item.get_compatible_crystal(self)
        if Settings::RAID_BATTLE_DEBUG
          pbMessage("DEBUG: Z-Crystal auto-assigned to #{self.name} (#{self.item_id})")
        end
      end
    end
  end
end

#-----------------------------------------------------------------------------
# Ensure editWildPokemon is never nil when cloned
#-----------------------------------------------------------------------------
module AdventureTileEffects
  MapTile.add(:Battle,
    proc { |id, tile, adventure, scene, dir, dirs|
      boss_id = scene.boss_tile.battle_id
      battle_id = scene.player_tile.battle_id
      if adventure.playtesting
        scene.pbAutoPosition(scene.player_tile, 6)
        adventure.outcome = 1 if battle_id == boss_id
        next dir
      end
      rules = scene.raid_battles[battle_id]
      next dir if rules[:battled]
      $game_temp.clear_battle_rules
      rules[:ko_count] = adventure.hearts
      adventure.boss_battled = (battle_id == boss_id)
      setBattleRule($PokemonGlobal.partner.nil? ? "3v1" : "2v1")
      raidType = GameData::RaidType.get(adventure.style)
      setBattleRule("environment", raidType.battle_environ)
      
      # [HOTFIX] Ensure editWildPokemon exists before cloning
      if !$game_temp.battle_rules["editWildPokemon"]
        setBattleRule("editWildPokemon", {})
      end
      
      pbSetRaidProperties(rules)
      raid_pkmn = rules[:pokemon].clone
      
      # [HOTFIX] Verify Z-Crystal on cloned Pokemon for Ultra Adventures
      if adventure.style == :Ultra
        if !raid_pkmn.hasZCrystal? && !raid_pkmn.ultra?
          raid_pkmn.item = GameData::Item.get_compatible_crystal(raid_pkmn)
          if Settings::RAID_BATTLE_DEBUG
            pbMessage("DEBUG: Z-Crystal assigned to cloned Pokemon #{raid_pkmn.name} (#{raid_pkmn.item_id})")
          end
        end
      end
      
      scene.pbAutoPosition(scene.player_tile, 6)
      continue = true
      pbFadeOutIn {
        adventure.last_battled = battle_id if adventure.floor == 1
        scene.map_sprites["pokemon_#{battle_id}"].visible = false
        scene.map_sprites["pokemon_#{battle_id}"].color.alpha = 0
        scene.map_sprites["pkmntype_#{battle_id}"].visible = false
        decision = WildBattle.start_core(raid_pkmn)
        decision = 2 if adventure.hearts == 0
        $game_temp.transition_animation_data = nil
        EventHandlers.trigger(:on_wild_battle_end, raid_pkmn.species_data.id, raid_pkmn.level, decision)
        continue = [1, 4].include?(decision)
        rules[:battled] = true
        scene.pbUpdateHearts
        $player.party.each { |p| p.heal if p.fainted? }
        if decision == 4 && (!adventure.boss_battled || adventure.endlessMode?)
          pkmn = adventure.captures.last
          pbFadeOutIn { pbAdventureMenuExchange(pkmn) }
        end
      }
      # Continues Adventure if raid Pokemon was captured or defeated.
      if continue
        scene.pbUpdateDarkness(true)
        adventure.battle_count += 1
        if adventure.boss_battled
          # Proceed to next floor if boss defeated in Endless Mode.
          if adventure.endlessMode?
            adventure.floor += 1
            $stats.endless_adventure_floors += 1
            next scene.pbResetLair
          # Proceed to rewards selection if boss defeated in Normal Mode.
          else
            adventure.outcome = 1
          end
        end
      # If the player's hearts have all been depleted, or the entire party has been KO'd:
      # -Decides if a new record should be set if playing in Endless Mode.
      elsif adventure.floor > 1
        record = $PokemonGlobal.raid_adventure_records[adventure.style]
        newRecord = record.nil? || record.empty? || adventure.floor > record[:floor]
        adventure.outcome = (newRecord) ? 1 : 2
      # -Decides if the lair route may be saved if playing in Normal Mode.
      else
        adventure.outcome = (adventure.boss_battled) ? 3 : 2
      end
      next dir
    }
  )
end

#-----------------------------------------------------------------------------
# [HOTFIX] Additional safety check when generating raid battles in adventures
#-----------------------------------------------------------------------------
class RaidBattle
  class << self
    alias zcrystal_fix_generate_raid_foe generate_raid_foe
    def generate_raid_foe(pkmn, rules)
      generated_pkmn = zcrystal_fix_generate_raid_foe(pkmn, rules)
      
      # [HOTFIX] Double-check Z-Crystal for Ultra style after generation
      if generated_pkmn.is_a?(Pokemon) && rules[:style] == :Ultra
        if !generated_pkmn.hasZCrystal? && !generated_pkmn.ultra? && !generated_pkmn.hasItem?
          generated_pkmn.item = GameData::Item.get_compatible_crystal(generated_pkmn)
          if Settings::RAID_BATTLE_DEBUG
            pbMessage("DEBUG: Z-Crystal assigned during generation to #{generated_pkmn.name} (#{generated_pkmn.item_id})")
          end
        end
      end
      
      return generated_pkmn
    end
  end
end

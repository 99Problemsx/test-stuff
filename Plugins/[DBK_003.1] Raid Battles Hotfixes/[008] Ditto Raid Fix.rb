#===============================================================================
# Fix for Ditto in Raid Battles
#===============================================================================
# Bug: Ditto causes baseMoves error in shield damage calculation
# Root Cause: baseMoves attribute may not exist or be nil for transformed Pokemon
#===============================================================================

#===============================================================================
# Fix baseMoves reference in raid shield damage calculation
#===============================================================================
# This prevents the error when Ditto (or transformed Pokemon) uses moves
#===============================================================================
class Battle::Battler
  alias ditto_raid_setRaidShieldHP setRaidShieldHP
  
  def setRaidShieldHP(amt, user = nil)
    return if !hasRaidShield?
    maxHP = @battle.raidRules[:shield_hp]
    oldShield = @shieldHP
    
    if $DEBUG && Input.press?(Input::CTRL)
      amt = (amt > 0) ? maxHP : -maxHP
    elsif user && amt < 0
      move = GameData::Move.try_get(user.lastMoveUsed)
      if move && move.damaging?
        amt -= 1 if user.pbOwnSide.effects[PBEffects::CheerOffense3] > 0
        case @battle.raidRules[:style]
        #-----------------------------------------------------------------------
        # Basic Raids
        #-----------------------------------------------------------------------
        when :Basic
          amt -= 1 if Effectiveness.super_effective?(@damageState.typeMod)
        #-----------------------------------------------------------------------
        # Ultra Raids
        #-----------------------------------------------------------------------
        when :Ultra
          # Fixed: Check if baseMoves exists and is not empty
          if user.respond_to?(:baseMoves) && user.baseMoves && !user.baseMoves.empty? && 
             user.lastMoveUsedIsZMove && move.zMove?
            amt -= 2
          elsif user.ultra?
            amt -= 1
          end
        #-----------------------------------------------------------------------
        # Max Raids
        #-----------------------------------------------------------------------
        when :Max
          # Fixed: Check if baseMoves exists and is not empty
          if user.respond_to?(:baseMoves) && user.baseMoves && !user.baseMoves.empty? && 
             user.dynamax? && move.dynamaxMove?
            amt -= 1
            amt -= 1 if user.gmax? && move.gmaxMove?
          end
        #-----------------------------------------------------------------------
        # Tera Raids
        #-----------------------------------------------------------------------
        when :Tera
          if user.tera?
            amt -= 1 if user.types.include?(user.lastMoveUsedType)
            amt -= 1 if user.typeTeraBoosted?(user.lastMoveUsedType)
          end
        end
      end
    end
    
    @shieldHP += amt
    @shieldHP = maxHP if @shieldHP > maxHP
    @shieldHP = 0 if @shieldHP < 0
    return if @shieldHP == oldShield
    
    PBDebug.log("[Raid mechanics] #{pbThis(true)} #{@index}'s raid shield HP changed (#{oldShield} => #{@shieldHP})")
    @battle.scene.pbRefreshOne(@index)
    @battle.scene.pbAnimateRaidShield(self, oldShield)
    @battle.pbDeluxeTriggers(@index, nil, "RaidShieldDamaged") if @shieldHP > 0 && @shieldHP < oldShield
    return if @shieldHP > 0
    return if @battle.pbAllFainted? || @battle.decision > 0
    
    @battle.pbDisplay(_INTL("The mysterious barrier disappeared!"))
    oldhp = @hp
    @hp -= @totalhp / 8
    @hp = 1 if @hp <= 1
    @battle.scene.pbHPChanged(self, oldhp)
    [:DEFENSE, :SPECIAL_DEFENSE].each do |stat|
      if pbCanLowerStatStage?(stat, self, nil, true)
        pbLowerStatStage(stat, 2, self, true, false, 0, true)
      end
    end
    @battle.raidRules.delete(:shield_hp)
    @battle.pbDeluxeTriggers(@index, nil, "RaidShieldBroken")
  end
end

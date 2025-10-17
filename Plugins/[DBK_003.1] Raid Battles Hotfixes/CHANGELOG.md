# Raid Battles Hotfixes - Changelog

## Version 1.0.5 (2025-10-17)

### Bug Fixes

#### [012] Ultra Adventure Z-Crystal Fix

- **Fixed**: Rare crash in Ultra Raids/Adventures when Pokémon load without a Z-Crystal
- **Fixed**: Random crashes when battling raid Pokémon in Ultra Adventures
- **Root Cause**:
  - Race condition where cloned Pokémon objects lose their Z-Crystal item during the cloning process
  - Missing `editWildPokemon` battle rule initialization before cloning raid Pokémon
  - Z-Crystal assignment logic could be skipped when `editedPkmn` conditions weren't met
  - The bug was intermittent because it depended on the state of battle rules at the moment of cloning
- **Solution**:
  - **Multiple Safety Layers**: Added three layers of Z-Crystal verification:
    1. Post-attribute check in `setRaidBossAttributes` to ensure Z-Crystals are assigned after all setup
    2. Pre-battle verification when cloning Pokémon in adventure battle tiles
    3. Post-generation check in `generate_raid_foe` for Ultra style raids
  - **Battle Rule Initialization**: Ensures `editWildPokemon` rule exists before cloning to prevent nil errors
  - **Debug Logging**: Added optional debug messages (when `RAID_BATTLE_DEBUG` is enabled) to track Z-Crystal assignments
  - All checks verify: Pokemon doesn't have Z-Crystal, isn't Ultra form, and doesn't have any item before assigning

---

## Version 1.0.4 (2025-10-13)

### Bug Fixes

#### [008] Ditto Raid Fix (Extended)

- **Fixed**: Ditto in Tera Raids using Struggle (no compatible moves)
- **Fixed**: Wobbuffet and other Pokémon without damaging moves in raids
- **Fixed**: Ditto causing `baseMoves` error during raid battles
- **Root Cause**:
  - Ditto only learns Transform, which cannot be Tera-typed
  - Some Pokémon lack damaging moves matching raid requirements
  - The `baseMoves` attribute may not exist for transformed Pokémon
- **Solution**:
  - **Moveset Failsafe System**: Automatically assigns appropriate moves when no viable moves are found:
    - **Tera Raids**: Tera Blast (works with any Tera type)
    - **Ultra/Max Raids**: Type-appropriate powerful moves (e.g., Flamethrower for Fire-types)
    - **Basic Raids**: Universal moves (Tackle, Body Slam, etc.)
  - **Shield Damage Fix**: Added safety checks for `baseMoves` attribute in Ultra and Max raid styles
  - Applies to all Pokémon with empty or non-damaging movesets

---

## Version 1.0.3

### Bug Fixes

#### [007] Unown Raid Fix

- **Fixed**: Unown not triggering raid shield
- **Fixed**: Unown giving no rewards after raid battles
- **Root Cause**: Unown only learns Hidden Power, which is banned in raid battles, resulting in an empty moveset
- **Solution**: Unown now receives a set of Psychic-type moves for raid battles (Psychic, Psyshock, Psybeam, Stored Power, Confusion, Zen Headbutt, Calm Mind, Amnesia)

#### [008] Ditto Raid Fix

- **Fixed**: Ditto causing `baseMoves` error during raid battles
- **Fixed**: Error message appearing but not crashing the game when Ditto attacks
- **Root Cause**: The `baseMoves` attribute may not exist or be nil for transformed Pokémon
- **Solution**: Added proper safety checks before accessing `baseMoves` in shield damage calculation for Ultra and Max raid styles

---

## Version 1.0.2

### Bug Fixes

#### [001] Z-Crystal Compatibility

- Fixed Z-Crystal compatibility issues

#### [002] Adventure Outcome Fix

- Fixed adventure outcome calculation errors

#### [003] Pokemon Storage Fix

- Fixed issues with Pokémon storage during raids

#### [004] Cheer Handler Fix

- Fixed cheer mechanic handler errors

#### [005] Raid Boss Detection Fix

- Fixed raid boss detection issues

#### [006] Level Validation Fix

- Fixed level validation errors in raid battles

---

## Credits

- **Lucidious89** - Original Raid Battles plugin
- **Nononever** - Bug reports and testing
- **Community** - Additional bug reports

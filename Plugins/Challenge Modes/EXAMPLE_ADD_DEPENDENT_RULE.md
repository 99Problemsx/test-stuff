# How to Add a Custom Challenge Rule with Dependencies

This guide shows you exactly how to add a new challenge rule that **requires another rule** to be selected first (like how Shiny Clause, Dupes Clause, and Gift Clause require "One Capture per Map").

---

## Example: Adding "Level Cap" that requires "Permafaint"

Let's create a new rule where your Pokémon can't exceed certain level caps, but it only makes sense if Permafaint is enabled.

---

### STEP 1: Define Your Rule in `000_Config.rb`

Add your rule to the `RULES` hash:

```ruby
:LEVEL_CAP => {
  :name  => _INTL("Level Cap"),
  :desc  => _INTL("Your Pokémon cannot exceed the level of the next Gym Leader's strongest Pokémon."),
  :order => 12  # Order determines display position in the menu
}
```

**Location:** Add this inside the `RULES = { }` hash in `000_Config.rb`, before the closing `}`

---

### STEP 2: Set Up the Dependency in `002_Rule Select.rb`

#### A) Define the dependency group (around line 71):

```ruby
def select_custom_rules
  selected_rules = []
  catch_clauses  = [:SHINY_CLAUSE, :DUPS_CLAUSE, :GIFT_CLAUSE]
  special_modes  = [:MONOTYPE_MODE, :RANDOMIZER_MODE, :HARDCORE_MODE]
  
  # ADD THIS LINE: Rules that require PERMAFAINT
  permafaint_dependent = [:LEVEL_CAP]
  
  vp = Viewport.new(0, 0, Graphics.width, Graphics.height)
```

#### B) Auto-remove dependent rules when base rule is disabled (around line 147):

```ruby
if selected_rules.include?(rule)
  selected_rules.delete(rule)
  catch_clauses.each { |r| selected_rules.delete(r) } if rule == :ONE_CAPTURE
  
  # ADD THIS LINE: Remove LEVEL_CAP when PERMAFAINT is disabled
  permafaint_dependent.each { |r| selected_rules.delete(r) } if rule == :PERMAFAINT
  
  selected_rules.push(:GAME_OVER_WHITEOUT) if !selected_rules.include?(:PERMAFAINT) && !selected_rules.include?(:GAME_OVER_WHITEOUT)
```

#### C) Add the dependency check (around line 151):

**BEFORE:**
```ruby
elsif (selected_rules.include?(:ONE_CAPTURE) && catch_clauses.include?(rule)) || 
      (selected_rules.include?(:PERMAFAINT) && rule == :GAME_OVER_WHITEOUT) ||
      !(catch_clauses + [:GAME_OVER_WHITEOUT] + special_modes).include?(rule) ||
      special_modes.include?(rule)
```

**AFTER:**
```ruby
elsif (selected_rules.include?(:ONE_CAPTURE) && catch_clauses.include?(rule)) || 
      (selected_rules.include?(:PERMAFAINT) && (permafaint_dependent.include?(rule) || rule == :GAME_OVER_WHITEOUT)) ||
      !(catch_clauses + permafaint_dependent + [:GAME_OVER_WHITEOUT] + special_modes).include?(rule) ||
      special_modes.include?(rule)
```

---

### STEP 3: Implement the Rule Logic

Create a new file or add to an existing file in the `Challenge Modes` folder:

**Example: `013_Level_Cap.rb`**

```ruby
# Level Cap Challenge Logic
EventHandlers.add(:on_wild_pokemon_created, :level_cap_wild,
  proc { |pkmn|
    next if !$PokemonGlobal.challenge_rules.include?(:LEVEL_CAP)
    # Your logic to enforce level cap on wild Pokemon
    max_level = get_current_level_cap()
    pkmn.level = [pkmn.level, max_level].min
  }
)

EventHandlers.add(:on_player_pokemon_gained_exp, :level_cap_exp,
  proc { |pkmn, exp_gained|
    next if !$PokemonGlobal.challenge_rules.include?(:LEVEL_CAP)
    max_level = get_current_level_cap()
    # Prevent Pokemon from leveling past the cap
    if pkmn.level >= max_level
      pkmn.exp = pkmn.growth_rate.minimum_exp_for_level(max_level)
    end
  }
)

def get_current_level_cap
  # Example: Return level based on badges
  badges = $player.badge_count
  case badges
  when 0 then return 15
  when 1 then return 20
  when 2 then return 25
  when 3 then return 30
  when 4 then return 35
  when 5 then return 40
  when 6 then return 45
  when 7 then return 50
  else return 100
  end
end
```

---

## How It Works in Game:

1. Player opens Challenge Mode selection
2. Player tries to select "Level Cap" → **BUZZER SOUND** (can't select)
3. Player selects "Permafaint" → **SUCCESS**
4. Player now selects "Level Cap" → **SUCCESS** (because Permafaint is enabled)
5. If player deselects "Permafaint" → "Level Cap" is **automatically removed**

---

## Template for Your Own Rules:

```ruby
# In 000_Config.rb - RULES hash:
:YOUR_RULE => {
  :name  => _INTL("Your Rule Name"),
  :desc  => _INTL("Description of what your rule does."),
  :order => 13
}

# In 002_Rule Select.rb - line ~71:
your_dependent_rules = [:YOUR_RULE]

# In 002_Rule Select.rb - line ~149:
your_dependent_rules.each { |r| selected_rules.delete(r) } if rule == :BASE_RULE

# In 002_Rule Select.rb - line ~152:
(selected_rules.include?(:BASE_RULE) && your_dependent_rules.include?(rule)) ||
```

---

## Multiple Dependencies Example:

If you want **multiple rules** to require the same base rule:

```ruby
# Line 71:
catch_clauses = [:SHINY_CLAUSE, :DUPS_CLAUSE, :GIFT_CLAUSE, :NEW_CLAUSE_A, :NEW_CLAUSE_B]
```

Now both `:NEW_CLAUSE_A` and `:NEW_CLAUSE_B` require `:ONE_CAPTURE`!

---

## Different Base Rule Example:

Want a rule to require `:MONOTYPE_MODE` instead?

```ruby
# Line 71:
monotype_dependent = [:STRICT_TYPE_CHECKING]

# Line 149:
monotype_dependent.each { |r| selected_rules.delete(r) } if rule == :MONOTYPE_MODE

# Line 152:
(selected_rules.include?(:MONOTYPE_MODE) && monotype_dependent.include?(rule)) ||
```

---

## Common Mistakes:

❌ **Don't forget** to add the dependency array to the `elsif` condition check  
❌ **Don't forget** to add the auto-remove line when base rule is disabled  
❌ **Don't forget** to include your dependency array in the exclusion list (line 153)

✅ **Do** test that the buzzer sound plays when trying to select without the base rule  
✅ **Do** test that dependent rules are removed when base rule is disabled  
✅ **Do** set appropriate `:order` values to control menu display order

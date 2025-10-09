# RMXP Event Importer Plugin
## Version 1.3 - Complete Edition

Create RPG Maker XP events from simple text files!

## 🎯 Features
- ✅ Create events from text files
- ✅ Update existing events automatically (no duplicates!)
- ✅ **50+ RMXP event commands** supported
- ✅ **Multiple event pages** with conditions
- ✅ **Move routes with 40+ movement commands**
- ✅ Compatible with RMXP Event Exporter
- ✅ Visible in RPG Maker XP editor
- ✅ Auto-import on game startup
- ✅ Debug menu integration

## 📦 Installation
1. Copy the `RMXP Event Importer` folder to `Plugins/`
2. Create the `EventImporter/` folder in your project root
3. Place your event text files in `EventImporter/`
4. Start the game - events will be imported automatically!

## 📝 Basic Format

```
MAP: 3

EVENT: NPC Name, X: 10, Y: 5
GRAPHIC: NPC 01
TRIGGER: Action
TEXT: Hello! I'm an NPC.
TEXT: This is line 2.
```

**⚠️ IMPORTANT**: Do NOT put empty lines within an event definition! Empty lines mark the end of an event.

## 🎮 Event Properties

### Basic Properties
```
EVENT: Name, X: x, Y: y          # Event name and position (REQUIRED)
GRAPHIC: filename                 # Character graphic
GRAPHIC: trainer_YOUNGSTER, 0    # With character index
TRIGGER: Action                   # Event trigger type
DIRECTION: Left                   # Initial facing direction
MOVE_TYPE: Random                 # Autonomous movement
MOVE_SPEED: 4                     # Movement speed (1-6)
MOVE_FREQ: 3                      # Movement frequency (1-6)
THROUGH: true                     # Walk through walls
ALWAYS_ON_TOP: true               # Always above player
DIRECTION_FIX: true               # Don't change direction
```

**Trigger Types:** `Action`, `Touch`, `Event_Touch`, `Autorun`, `Parallel`  
**Directions:** `Up`, `Down`, `Left`, `Right`  
**Move Types:** `Fixed`, `Random`, `Approach`, `Custom`

### 📄 Multiple Pages
```
EVENT: Multi Page NPC, X: 12, Y: 5
GRAPHIC: NPC 01
TEXT: This is page 1
SELF_SWITCH: A, ON

NEW_PAGE
GRAPHIC: NPC 02
CONDITION_SELF_SWITCH: A
TEXT: This is page 2 (shows when self switch A is ON)
```

### 🔒 Page Conditions
```
CONDITION_SWITCH: 10, ON              # Require switch 10 to be ON
CONDITION_SELF_SWITCH: A              # Require self switch A
CONDITION_VARIABLE: 5 >= 10           # Require variable 5 >= 10
```

**Operators:** `>=`, `<=`, `==`, `>`, `<`

## 💬 Dialogue & Text Commands

### Simple Text
```
TEXT: Hello there!
TEXT: How are you today?
```

### Choices
```
CHOICE: Yes, No, Maybe
CONDITIONAL: CHOICE == 0
  TEXT: You chose Yes!
CONDITIONAL: CHOICE == 1
  TEXT: You chose No!
CONDITIONAL: ELSE
  TEXT: You chose Maybe!
```

### Scripts
```
SCRIPT: pbMessage("Hello!")
SCRIPT: pbHealAll
SCRIPT: pbTrainerBattle(:YOUNGSTER, "Joey", "You win!", false)
```

**Multi-line scripts:**
```
SCRIPT: pbPokemonMart([
SCRIPT:   :POTION,
SCRIPT:   :POKEBALL,
SCRIPT:   :ANTIDOTE
SCRIPT: ])
```

## 🎯 Control Flow

### Conditionals
```
# Switch condition
CONDITIONAL: SWITCH 10 == ON
  TEXT: Switch 10 is on!
CONDITIONAL: ELSE
  TEXT: Switch 10 is off!

# Variable condition
CONDITIONAL: VARIABLE 5 >= 10
  TEXT: Variable is at least 10

# Choice condition
CONDITIONAL: CHOICE == 0
  TEXT: First option chosen
```

### Loops & Labels
```
# Label/Jump loop
VARIABLE: 10, = 0
LABEL: CountLoop
TEXT: Count: \v[10]
VARIABLE: 10, + 1
CONDITIONAL: VARIABLE 10 < 5
  JUMP_TO_LABEL: CountLoop

# Infinite loop with break
LOOP_START
  TEXT: Press button to continue
  BREAK_LOOP
LOOP_END
```

### Control Commands
```
EXIT_EVENT               # Stop event execution
ERASE_EVENT             # Erase this event permanently
CALL_COMMON_EVENT: 1    # Call common event #1
COMMENT: Dev note here  # Add comment (invisible in game)
```

## 🎛️ Game State Commands

### Switches & Variables
```
SWITCH: 10, ON                    # Turn switch 10 ON
SWITCH: 20, OFF                   # Turn switch 20 OFF
SELF_SWITCH: A, ON                # Turn self switch A ON
VARIABLE: 5, = 100                # Set variable 5 to 100
VARIABLE: 5, + 10                 # Add 10 to variable 5
VARIABLE: 5, - 5                  # Subtract 5 from variable 5
VARIABLE: 5, = VAR[10]            # Set variable 5 to value of variable 10
```

### Items, Money & Pokemon
```
ITEM: POTION, 5                   # Give 5 Potions
POKEMON: PIKACHU, 25              # Give level 25 Pikachu
CHANGE_GOLD: +1000                # Add 1000 gold
CHANGE_GOLD: -500                 # Remove 500 gold
CHANGE_ITEMS: 1, +5               # Add 5 of item ID 1
CHANGE_ITEMS: 2, -3               # Remove 3 of item ID 2
CHANGE_PARTY: 1, ADD              # Add actor 1 to party
CHANGE_PARTY: 2, REMOVE           # Remove actor 2 from party
```

## 🚶 Movement & Transfer

### Player Transfer
```
TRANSFER: 2, 10, 15, Down
```
**Format:** `map_id, x, y, direction`

### 🎬 Move Routes
```
SET_MOVE_ROUTE: PLAYER, THROUGH_ON, MOVE_UP, MOVE_UP, THROUGH_OFF
SET_MOVE_ROUTE: 0, TURN_LEFT, TURN_RIGHT, TURN_UP
WAIT_FOR_MOVE
```

**Target:**
- `PLAYER` = Player character
- `0` = This event
- `5` = Event ID 5

#### Movement Commands (40+ available!)

**Basic Movement:**
- `MOVE_DOWN`, `MOVE_LEFT`, `MOVE_RIGHT`, `MOVE_UP`
- `MOVE_LOWER_LEFT`, `MOVE_LOWER_RIGHT`
- `MOVE_UPPER_LEFT`, `MOVE_UPPER_RIGHT`
- `MOVE_RANDOM`
- `MOVE_TOWARD_PLAYER`, `MOVE_AWAY_FROM_PLAYER`
- `STEP_FORWARD`, `STEP_BACKWARD`

**Turning:**
- `TURN_DOWN`, `TURN_LEFT`, `TURN_RIGHT`, `TURN_UP`
- `TURN_90_RIGHT`, `TURN_90_LEFT`, `TURN_180`
- `TURN_90_RIGHT_OR_LEFT`, `TURN_RANDOM`
- `TURN_TOWARD_PLAYER`, `TURN_AWAY_FROM_PLAYER`

**Animation Options:**
- `MOVE_ANIMATION_ON/OFF` - Walking animation
- `STOP_ANIMATION_ON/OFF` - Stepping animation while stopped
- `DIRECTION_FIX_ON/OFF` - Lock facing direction
- `THROUGH_ON/OFF` - Walk through solid tiles
- `ALWAYS_ON_TOP_ON/OFF` - Display above other events

### Set Event Position
```
SET_EVENT_LOCATION: 5, 20, 15
```
**Format:** `event_id, x, y`

## 🎨 Screen Effects

### Fading
```
FADEOUT               # Fade to black
WAIT: 20             # Wait 20 frames
TRANSFER: 2, 10, 10, Down
FADEIN               # Fade in from black
```

### Screen Tone (Color Tint)
```
CHANGE_SCREEN_TONE: -255, -255, -255, 0, 20
```
**Format:** `red, green, blue, gray, duration`
- Values: -255 to +255
- Negative = darker, Positive = brighter
- Duration in frames (60 = 1 second)

**Examples:**
```
CHANGE_SCREEN_TONE: -255, -255, -255, 0, 30    # Fade to black
CHANGE_SCREEN_TONE: 0, 0, 0, 0, 30             # Back to normal
CHANGE_SCREEN_TONE: 0, 0, -100, 0, 20          # Blue tint (night)
CHANGE_SCREEN_TONE: 100, 50, 0, 0, 20          # Orange tint (sunset)
```

### Screen Flash
```
SCREEN_FLASH: 255, 0, 0, 255, 20
```
**Format:** `red, green, blue, alpha, duration`
- Values: 0-255
- Alpha: 0 = invisible, 255 = solid

### Screen Shake
```
SCREEN_SHAKE: 5, 5, 30
```
**Format:** `power, speed, duration`

### Player Transparency
```
CHANGE_TRANSPARENT: ON     # Make player invisible
CHANGE_TRANSPARENT: OFF    # Make player visible
```

## 🔊 Sound Effects

```
PLAY_SE: Door exit
PLAY_SE: Battle damage
PLAY_BGM: Route 1
PLAY_ME: Victory
```

Sound files must exist in Audio/SE, Audio/BGM, or Audio/ME folders.

## 🖼️ Pictures

```
SHOW_PICTURE: 1, picture1, 100, 100    # Show picture 1 at (100,100)
MOVE_PICTURE: 1, 200, 200              # Move picture 1 to (200,200)
ERASE_PICTURE: 1                       # Erase picture 1
```

**Format:** `picture_number (1-20), filename, x, y`

## ⏱️ Timing

```
WAIT: 30              # Wait 30 frames
WAIT: 60              # Wait 60 frames = 1 second
WAIT_FOR_MOVE         # Wait until move route completes
```

## 🔧 Menu & System

```
CHANGE_MENU_ACCESS: DISABLE        # Disable menu access
CHANGE_MENU_ACCESS: ENABLE         # Enable menu access
CHANGE_SAVE_ACCESS: DISABLE        # Disable saving
CHANGE_SAVE_ACCESS: ENABLE         # Enable saving
CHANGE_ENCOUNTER: DISABLE          # Disable wild encounters
CHANGE_ENCOUNTER: ENABLE           # Enable wild encounters
```

## 📚 Complete Examples

### Example 1: Simple Door Event
```
EVENT: House Door, X: 10, Y: 5
GRAPHIC: doors5
TRIGGER: Touch
SET_MOVE_ROUTE: PLAYER, THROUGH_ON, MOVE_UP, THROUGH_OFF
WAIT_FOR_MOVE
PLAY_SE: Door exit
FADEOUT
WAIT: 10
TRANSFER: 2, 15, 20, Down
FADEIN
```

### Example 2: Quest NPC (3 Pages)
```
EVENT: Quest Giver, X: 12, Y: 7
GRAPHIC: NPC 04
TRIGGER: Action
TEXT: Hello! I need help finding my Pokemon.
CHOICE: I'll help!, Maybe later
CONDITIONAL: CHOICE == 0
  TEXT: Thank you so much!
  TEXT: I think it went to Route 1.
  SWITCH: 50, ON
  SELF_SWITCH: A, ON
CONDITIONAL: ELSE
  TEXT: Please come back if you change your mind.

NEW_PAGE
GRAPHIC: NPC 04
CONDITION_SELF_SWITCH: A
CONDITION_SWITCH: 50, ON
TEXT: Did you find my Pokemon?
CHOICE: Yes! Here it is., Still looking...
CONDITIONAL: CHOICE == 0
  TEXT: Oh wonderful! Thank you!
  TEXT: Please take this as a reward.
  ITEM: POTION, 5
  CHANGE_GOLD: +1000
  POKEMON: EEVEE, 10
  SELF_SWITCH: B, ON
  SWITCH: 50, OFF
CONDITIONAL: ELSE
  TEXT: Please keep looking!
  
NEW_PAGE
GRAPHIC: NPC 04
CONDITION_SELF_SWITCH: B
TEXT: Thanks again for your help!
TEXT: We're so happy together now.
```

### Example 3: Treasure Chest
```
EVENT: Treasure Chest, X: 15, Y: 10
GRAPHIC: chest1
TRIGGER: Action
CONDITIONAL: SWITCH 60 == OFF
  TEXT: You found a treasure chest!
  PLAY_SE: Item get
  TEXT: Obtained 1000 gold and 3 Rare Candies!
  CHANGE_GOLD: +1000
  ITEM: RARE_CANDY, 3
  SWITCH: 60, ON
  SELF_SWITCH: A, ON
CONDITIONAL: ELSE
  TEXT: The chest is empty.

NEW_PAGE
GRAPHIC: chest1, 1
CONDITION_SELF_SWITCH: A
TRIGGER: Action
TEXT: The chest is empty.
```

### Example 4: Healing Station
```
EVENT: Healing Station, X: 20, Y: 8
GRAPHIC: healingmachine
TRIGGER: Action
TEXT: Welcome to the Healing Station!
TEXT: Let me heal your Pokemon.
PLAY_SE: Pkmn heal
FADEOUT
WAIT: 20
SCRIPT: pbHealAll
FADEIN
TEXT: Your Pokemon are fully healed!
TEXT: Come back anytime!
```

### Example 5: Spinning NPC
```
EVENT: Dizzy Guy, X: 18, Y: 12
GRAPHIC: NPC 05
TRIGGER: Action
TEXT: Watch me spin!
SET_MOVE_ROUTE: 0, TURN_RIGHT, TURN_DOWN, TURN_LEFT, TURN_UP
WAIT_FOR_MOVE
SET_MOVE_ROUTE: 0, TURN_RIGHT, TURN_DOWN, TURN_LEFT, TURN_UP
WAIT_FOR_MOVE
TEXT: I'm so dizzy now!
```

## 🐛 Debugging

### Debug Menu (F9)
1. **Import Events Now** - Manually trigger import
2. **Clear Imported Events** - Remove all imported events from Map 003

### Console Output
The plugin shows detailed output during startup:
```
Importing events from: test_simple.txt
Processing map 3
Parsing line: EVENT: Simple NPC, X: 10, Y: 5
Event has 1 page(s)
Added event: Simple NPC at (10, 5)
```

## 💡 Tips & Best Practices

1. **No Empty Lines** - Don't put empty lines within event definitions (they mark the end)
2. **Test Incrementally** - Start with simple events, add complexity gradually
3. **Use Comments** - Add `COMMENT:` lines for documentation
4. **Backup Maps** - Always backup Data/MapXXX.rxdata before importing
5. **Check with Exporter** - Use Event Exporter plugin to verify event structure
6. **Consistent IDs** - Use the same switch/variable IDs across related events
7. **Self Switches** - Best for simple per-event state (A, B, C, D)
8. **Regular Switches** - Best for global game state
9. **Variables** - Good for counters, timers, progression tracking

## ⚠️ Known Limitations

**Not Yet Implemented:**
- Jump commands with X/Y parameters in move routes
- Graphic changes during move routes
- SE/Script commands in move routes
- Wait commands in move routes
- Complex page graphic patterns

**Text Formatting:**
- Use `\v[n]` for variables in text
- Use `\n[n]` for actor names in text
- Some special characters may need escaping

## 📜 Changelog

### Version 1.3 - Complete Edition
- **🔧 MAJOR FIX:** Corrected all Move Command codes (they were completely wrong!)
  - `MOVE_UP` was 1, now correctly 4
  - `THROUGH_ON` was 42, now correctly 37
  - All 40+ move commands now have correct codes
- ✅ SET_MOVE_ROUTE fully working and Event Exporter compatible
- ✅ Added DIRECTION property for events
- ✅ Fixed SCREEN_FLASH to use Color (was incorrectly using Tone)
- ✅ Added 35 movement commands
- ✅ Full compatibility with RMXP Event Exporter verified

### Version 1.2
- Added 50+ RMXP event commands
- Added CHANGE_SCREEN_TONE for color tinting
- Added screen effects (shake, flash, fade)
- Added picture commands (show, move, erase)
- Added gold/items/party management commands
- Added menu/system access controls

### Version 1.1
- Added multiple event pages (NEW_PAGE)
- Added page conditions (switch, self switch, variable)
- Added self switches (A, B, C, D)
- Added variable operations
- Added item and Pokemon commands
- Added choices and conditionals

### Version 1.0
- Initial release
- Basic event creation from text files
- TEXT, SCRIPT, SWITCH commands
- GRAPHIC, TRIGGER properties
- Debug menu integration

## 📖 More Examples

See `EventImporter/advanced_examples.txt.bak` for **15 complex example events** including:
- Multi-page quest NPCs
- Door events with followers
- Treasure chests with state
- Weather control systems
- Shop NPCs
- Trainer battles
- Picture galleries
- Counter/loop demonstrations
- Screen effect showcases
- And more!

Rename the file to `.txt` to import them all!

## 🎓 Credits

**Created for:** Pokemon Essentials v21.1  
**Compatible with:** RMXP Event Exporter plugin  
**Version:** 1.3  

---

**Happy Event Creating!** 🎮✨

*Questions? Issues? Check the examples or create detailed events step-by-step!*

===============================================================================
RMXP MAP BUILDER - Documentation
===============================================================================
Version: 1.0.0
Author: AI Assistant
Compatible with: Pokemon Essentials v21+ and RMXP Event Importer

===============================================================================
OVERVIEW
===============================================================================

The Map Builder allows you to create maps tile-by-tile using simple text files.
Instead of manually placing tiles in RPGXP, you can design your map layout in
a text editor using ASCII characters.

===============================================================================
HOW TO USE
===============================================================================

1. Create a new file in EventImporter/ folder
2. Name it: mapXXX.map (e.g., map022.map for Map 22)
3. Design your layout using tile symbols (see legend below)
4. Save the file
5. Start the game - the map will be automatically built!

===============================================================================
FILE FORMAT
===============================================================================

# Comments start with #
MAP: 22                 # Which map to build
SIZE: 20x15            # Optional: specify size (auto-detected if omitted)
TILESET: 1             # Optional: which tileset to use (1 = Outside)

# Custom tiles (optional)
TILE: H = layer1:100, layer2:200, layer3:0

# Layout starts here
LAYOUT:
gggggggggggggggggggg
gggGGGGGGGGGGGgggggg
...etc...

===============================================================================
TILE SYMBOL LEGEND - Outside Tileset
===============================================================================

TERRAIN:
  .  = Empty/Grass base
  g  = Grass (normal)
  G  = Tall grass (encounters)
  p  = Path/dirt
  P  = Paved path/road
  s  = Sand
  S  = Sand with detail

WATER:
  w  = Water (normal)
  W  = Deep water
  ~  = Water edge

NATURE:
  t  = Tree (small)
  T  = Big tree
  f  = Flower
  F  = Flower patch

OBSTACLES:
  r  = Rock/mountain
  R  = Big rock
  #  = Wall/impassable

STRUCTURES:
  b  = Bridge
  B  = Bridge post
  d  = Door/entrance
  D  = Big door
  l  = Ledge (small)
  L  = Big ledge

SPECIAL:
  ^  = Sign
  *  = Special tile

===============================================================================
CUSTOM TILE DEFINITIONS
===============================================================================

You can define your own tile symbols with specific tile IDs:

TILE: H = layer1:100, layer2:200, layer3:0
TILE: X = layer1:150, layer2:0, layer3:0

Then use H and X in your layout!

To find tile IDs:
1. Open RPGXP
2. Open the tileset in Database
3. Count tiles from top-left (0, 8, 16, 24, 32...)
4. Each row is +8 tiles
5. Formula: (row * 8 + column) * 8 for autotiles

===============================================================================
EXAMPLE LAYOUTS
===============================================================================

SIMPLE ROUTE:
####################
#gggggggggggggggggg#
#ggttggggggggggttgg#
#ggttggggggggggttgg#
#ggggppppppppgggggg#
#gggpPPPPPPPPpggggg#
#gggpPPPPPPPPpggggg#
#ggggppppppppgggggg#
#gggggggggggggggggg#
####################

LAKE AREA:
####################
#ggggggg~~~~wwwwwww#
#gggggg~~~~wwwwwwww#
#ggggg~~~~wwwwwwwww#
#ggggpppp~~wwwwwwww#
#gggpPPPP~~wwwwwwww#
#gggpPPPPp~wwwwwwww#
#ggggppppp~wwwwwwww#
#ggggggggg~wwwwwwww#
####################

TOWN SQUARE:
PPPPPPPPPPPPPPPPPPPp
PPPPggggggggggggPPPp
PPPPggggggggggggPPPp
PPPPggggggggggggPPPp
PPPPggggggggggggPPPp
PPPPppppppppppppPPPp
PPPPpPPPPPPPPPPpPPPp
PPPPpPPPPPPPPPPpPPPp
PPPPppppppppppppPPPp
PPPPPPPPPPPPPPPPPPPp

===============================================================================
TIPS & TRICKS
===============================================================================

1. Start simple - create a basic layout first, then add details
2. Use comments (#) to organize your layout sections
3. Keep layouts in a grid - use a monospace font editor
4. Test small sections before building large maps
5. Combine with Event Importer - build map layout + import events!
6. Save backups of your .map files
7. Use SIZE: command to pre-define map dimensions

===============================================================================
WORKFLOW: BUILDING A COMPLETE MAP
===============================================================================

Step 1: Create map layout
  - Create mapXXX.map file
  - Design tile layout

Step 2: Create events (optional)
  - Create mapXXX_events.txt file
  - Define events as usual

Step 3: Start game
  - Map Builder runs first (builds tiles)
  - Event Importer runs second (adds events)
  - Both systems work together!

Step 4: Verify in RPGXP
  - Open RPGXP
  - Check Map XXX
  - Tiles and events should both be there!

===============================================================================
TROUBLESHOOTING
===============================================================================

Q: Map is all black/wrong tiles
A: Check TILESET: value, make sure it's set correctly (1 = Outside)

Q: Map is too small
A: Add SIZE: command, or the system will auto-detect from layout

Q: Custom tiles not working
A: Check TILE: format - must be layer1:ID, layer2:ID, layer3:ID

Q: Map not building
A: Check filename format (mapXXX.map) and check Debug Window for errors

Q: Tiles are wrong IDs
A: Tile IDs depend on tileset structure - may need to adjust TILE_SYMBOLS

===============================================================================
ADVANCED: FINDING TILE IDS
===============================================================================

RMXP tiles are organized as:
- Autotiles (animated): IDs 384-511 (layer 2)
- Regular tiles: IDs 0-383 (layer 1)

To find the ID of a specific tile:
1. Autotiles are numbered 384 + (autotile_index * 48)
2. Regular tiles are numbered (row * 8 + column)

Example: Grass autotile (first autotile) = 384
Example: Tree in tileset at row 5, col 2 = (5 * 8) + 2 = 42

===============================================================================
SUPPORT
===============================================================================

Check Debug Window for build messages:
- "Building Map X from layout"
- "SUCCESS: Map X built successfully!"
- Error messages will show what went wrong

The system integrates with Event Importer, so both work together seamlessly!

===============================================================================

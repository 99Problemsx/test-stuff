# Chimney Smoke System

Ein System für animierten Schornstein-Rauch in Pokémon Essentials v21.1.

## Features

- ✅ Präzise Pixel-Positionierung (keine Tile-Begrenzung)
- ✅ Animierte Character-Grafiken
- ✅ Tag/Nacht-System Integration (Rauch nur am Tag)
- ✅ Automatische Aktualisierung bei Zeitwechsel
- ✅ Einfache Definition via Code
- ✅ Debug-Tools zum Testen

## Installation

1. Copy the `[006] Chimney Smoke System` folder to `Plugins/`
2. Create a wind graphic in `Graphics/Characters/` (e.g. `wind_leaves.png`)
3. Define your wind effects in `[004] Wind_Definitions.rb`

## Wind Graphic Format

The graphic should be in character format:

- 4 columns (animations: 0-3)
- 4 rows (directions: Down, Left, Right, Up)
- Recommended size: 128x128 pixels (32x32 per frame)

## Usage

### Add Wind Effect

Edit `[004] Wind_Definitions.rb`:

```ruby
pbAddWindEffect(:wind_leaves, 100, 200, "wind_leaves", 2, :left)
```

### Parameters

- **id**: Unique symbol ID (e.g. `:wind1`)
- **x**: Pixel X position
- **y**: Pixel Y position
- **bitmap_path**: Filename of the graphic (without .png)
- **wind_strength**: 1, 2, or 3 (affects animation speed)
- **direction**: `:left` for right-to-left animation

### Remove Wind Effect

```ruby
pbRemoveWindEffect(:wind_leaves)
```

- `:direction` - 2=unten, 4=links, 6=rechts, 8=oben
- `:speed` - Animationsgeschwindigkeit (FPS)
- `:opacity` - Deckkraft (0-255)

## Position finden

### Methode 1: Debug-Befehl

1. Drücke **Strg+Shift+P** im Spiel
2. Die aktuelle Pixel-Position wird angezeigt
3. Verwende diese Werte für `x` und `y`

### Methode 2: Von Tile-Koordinaten

- X (Pixel) = Tile-X × 32
- Y (Pixel) = Tile-Y × 32

Beispiel: Tile (8, 16)

- X = 8 × 32 = 256
- Y = 16 × 32 = 512

### Position anpassen

- Um nach **rechts** zu verschieben: X erhöhen (z.B. +4)
- Um nach **links** zu verschieben: X verringern (z.B. -4)
- Um nach **unten** zu verschieben: Y erhöhen
- Um nach **oben** zu verschieben: Y verringern

## Debug-Befehle

- **Strg+Shift+C**: Zeigt alle Rauch-Effekte auf der aktuellen Map
- **Strg+Shift+P**: Zeigt die aktuelle Spieler-Position in Pixeln

## Integration mit Dynamic Lighting System

Das System erkennt automatisch das Night Tileset System und aktualisiert sich bei Zeitänderungen. Falls nicht installiert, verwendet es einen eigenen Day/Night-Tracker.

## Beispiel: Purple House auf Map 43

```ruby
# Event war bei Tile (8, 16) = Pixel (256, 512)
# Rauch war zu weit links, daher +4 auf X
pbAddChimneySmoke(:purple_house_smoke, 43, 260, 512, "smoke", true)
```

## Troubleshooting

**Rauch wird nicht angezeigt:**

- Prüfe, ob die Grafik in `Graphics/Characters/` existiert
- Verwende **Strg+Shift+C** für Debug-Info
- Stelle sicher, dass es Tag ist (wenn `day_only: true`)

**Rauch ist falsch positioniert:**

- Verwende **Strg+Shift+P** um die richtige Position zu finden
- Passe X/Y Werte in kleinen Schritten an (±2-4 Pixel)

**Rauch verschwindet nicht nachts:**

- Setze `day_only: true` in der Definition
- Teste mit **Strg+Shift+C** ob die Sichtbarkeit korrekt ist

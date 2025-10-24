# 🎮 MKXP-Z Konfiguration für Pokémon Essentials v21.1

## ✅ Installiert & Konfiguriert

Die `mkxp.json` wurde optimiert für **Pokémon Essentials v21.1** mit MKXP-Z.

## 📋 Aktuelle Einstellungen

### Display
- **Auflösung**: 512x384 (Essentials Standard)
- **Skalierung**: Nearest-Neighbor (pixelig, scharf - ideal für Pixel-Art)
- **Aspect Ratio**: Fixed (4:3 Seitenverhältnis)
- **Fullscreen**: Aus (Alt+Enter zum Toggle)
- **Resizable**: Ja

### Performance
- **Framerate**: 40 FPS (Essentials Standard)
- **Frame Skip**: An (bessere Performance)
- **VSync**: An (kein Screen Tearing)
- **Path Cache**: An (schnelleres Laden)

### Audio
- **BGM Volume**: 100%
- **SE Volume**: 100%
- **SE Sources**: 6 (parallel abspielbare Sound Effects)

### Compatibility
- **RGSS Version**: 1 (RGSS1/XP)
- **Reset (F12)**: Aktiviert
- **Blitting**: Aktiviert (bessere Performance)

## 🎨 Skalierungs-Optionen

Falls du die Skalierung ändern möchtest, setze `smoothScaling` auf:

```json
"smoothScaling": 0  // Nearest-Neighbor (EMPFOHLEN - scharf & pixelig)
"smoothScaling": 1  // Bilinear (weicher)
"smoothScaling": 2  // Bicubic (sehr weich)
"smoothScaling": 3  // Lanczos3 (hochqualitativ)
"smoothScaling": 4  // xBRZ (speziell für Pixel-Art)
```

**Empfehlung**: Behalte `0` für authentisches Retro-Gefühl! 🎮

## ⚡ Performance-Tipps

### Wenn das Spiel zu langsam läuft:
- `"frameSkip": true` aktivieren (schon gesetzt)
- `"vsync": false` setzen (kann Screen Tearing verursachen)
- `"enableBlitting": true` aktivieren (schon gesetzt)

### Wenn das Spiel zu schnell läuft:
- `"fixedFramerate": 40` beibehalten (Essentials Standard)
- `"syncToRefreshrate": false` beibehalten

## 🖥️ Tastenkombinationen

- **F2**: FPS-Anzeige an/aus
- **F12**: Soft Reset (wenn aktiviert)
- **Alt+Enter**: Fullscreen Toggle
- **Alt+F4**: Spiel beenden

## 🔧 Troubleshooting

### Text wird nicht angezeigt
```json
"solidFonts": true
"subImageFix": true
```

### Grafik-Glitches
```json
"subImageFix": true
"maxTextureSize": 2048
```

### Audio-Probleme
```json
"SE.sourceCount": 8  // Mehr Sound-Kanäle
```

## 📁 Dateien

```
Backup_Clean_2025-10-03_23-49/
├── Game.exe              ← MKXP-Z (umbenannt)
├── mkxp.json            ← Optimierte Config
├── mkxp.json.backup     ← Original Backup
├── *.dll                ← Dependencies
├── Data/
├── Graphics/
└── PBS/
```

## 🚀 Start

Einfach `Game.exe` starten - MKXP-Z lädt automatisch die `mkxp.json` Konfiguration!

## 🔄 Zurück zur Original-Config

Falls du Probleme hast:
```powershell
Copy-Item "mkxp.json.backup" "mkxp.json" -Force
```

---

**Viel Spaß mit deinem optimierten Pokémon Essentials Spiel! 🎉**

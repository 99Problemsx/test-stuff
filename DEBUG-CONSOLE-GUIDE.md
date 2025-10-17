# 🎨 MKXP-Z Debug Console - Enhanced

## ✨ Features

### 🖥️ Farbige PowerShell Console
- **Strukturierte Ausgabe** mit Farben und Symbolen
- **Zeitstempel** für alle Events
- **Process-Monitoring** (PID-Anzeige)
- **Exit-Code Tracking**
- **Tastenkürzel-Übersicht**

### 📊 Debug-Informationen

Die `mkxp.json` wurde erweitert um:
- `"debugMode": true` - Aktiviert Debug-Features
- `"printFPS": true` - FPS in Console
- `"displayFPS": true` - FPS im Fenster-Titel

## 🚀 Verwendung

### Option 1: Batch-File (Einfach)
```batch
Doppelklick auf: Launch-Debug.bat
```

### Option 2: PowerShell-Script
```powershell
.\Launch-Debug.ps1
```

### Option 3: Direkt
```batch
Game.exe
```

## 🎨 Console-Features

### Farb-Schema:
- 🟦 **Cyan**: Überschriften, System-Info
- 🟩 **Green**: Erfolgs-Meldungen
- 🟨 **Yellow**: Wichtige Labels
- 🟥 **Red**: Fehler
- ⬜ **Gray**: Timestamps, Details

### Beispiel-Ausgabe:
```
╔══════════════════════════════════════════════════════════╗
║          🎮 MKXP-Z Enhanced Debug Console 🎮            ║
╚══════════════════════════════════════════════════════════╝

Game: Pokémon Essentials v21.1
Engine: MKXP-Z 2.4.2/4e8ce16
Path: C:\...\Backup_Clean_2025-10-03_23-49

──────────────────────────────────────────────────────────

[12:34:56] Starting game...

[12:34:56] Game process started (PID: 12345)

Debug Info:
  • Press F2 in game to toggle FPS display
  • Press F12 to soft reset
  • Press Alt+Enter for fullscreen

──────────────────────────────────────────────────────────
```

## ⚙️ mkxp.json Debug-Einstellungen

### Aktivierte Features:
```json
{
    "debugMode": true,        // Debug-Modus an
    "printFPS": true,         // FPS in Console
    "displayFPS": true,       // FPS im Titel
    "rgssVersion": 1,         // RGSS1/XP
    "fixedFramerate": 40,     // 40 FPS für Essentials
    "frameSkip": true,        // Performance-Boost
    "vsync": true,            // Smooth Display
    "enableReset": true,      // F12 Reset
    "winResizable": true      // Skalierbar
}
```

### Zusätzliche Debug-Optionen:

**Performance Monitoring:**
```json
"printFPS": true              // Zeigt FPS in Console
"displayFPS": true            // Zeigt FPS im Fenster
```

**Script Debugging:**
```json
"useScriptNames": true        // Zeigt Script-Namen in Errors
"debugMode": true             // Aktiviert Debug-Features
```

**Custom Scripting:**
```json
"customScript": "debug.rb"    // Lade custom Debug-Script
```

## 🎮 In-Game Tastenkürzel

### Standard:
- **F2**: FPS-Anzeige Toggle
- **F12**: Soft Reset
- **Alt+Enter**: Fullscreen Toggle
- **Alt+F4**: Spiel beenden

### Debug (wenn debugMode aktiv):
- Zusätzliche Debug-Info verfügbar
- Script-Fehler werden detaillierter angezeigt

## 📋 Log-Dateien

MKXP-Z erstellt automatisch Logs:
- **stderr.txt**: Fehler-Log
- **stdout.txt**: Normale Ausgabe

Diese findest du im Game-Verzeichnis.

## 🔧 Anpassungen

### Console-Farben ändern:
Bearbeite `Launch-Debug.ps1`:
```powershell
$host.UI.RawUI.BackgroundColor = "Black"  # Hintergrund
$host.UI.RawUI.ForegroundColor = "White"  # Vordergrund
```

### Mehr Debug-Ausgaben:
Bearbeite `mkxp.json`:
```json
"printFPS": true              // FPS-Counter in Console
"debugMode": true             // Mehr Debug-Info
"useScriptNames": true        // Script-Namen bei Fehlern
```

## 💡 Profi-Tipps

### 1. Kombiniere mit Windows Terminal
Windows Terminal unterstützt:
- 🎨 True Color
- 🖼️ Transparenz
- ⚡ GPU-Beschleunigung
- 📑 Tabs

### 2. Verwende einen Log-Viewer
Für `stderr.txt` und `stdout.txt`:
- **Notepad++** mit Tail-Plugin
- **BareTail** (kostenlos)
- **Visual Studio Code** mit Auto-Refresh

### 3. Performance-Profiling
Aktiviere in `mkxp.json`:
```json
"printFPS": true,
"syncToRefreshrate": false,
"frameSkip": true
```

Dann beobachte die Console für Performance-Daten.

## 🐛 Troubleshooting

### Console zeigt nichts:
- Stelle sicher, dass `debugMode: true` gesetzt ist
- Prüfe ob `Launch-Debug.ps1` korrekt ausgeführt wird
- Verwende `Launch-Debug.bat` statt direktem PowerShell

### Farben werden nicht angezeigt:
- Verwende Windows Terminal statt CMD
- Oder: Batch-File mit `color 0A` (grün auf schwarz)

### FPS wird nicht ausgegeben:
- Setze `printFPS: true` in `mkxp.json`
- Restart das Spiel

## 📚 Weitere Resources

- **MKXP-Z Docs**: https://github.com/mkxp-z/mkxp-z/wiki
- **Essentials Wiki**: https://essentialsdocs.fandom.com/
- **Debug Guide**: In diesem Projekt-Ordner

---

**Viel Spaß beim Debuggen! 🚀**

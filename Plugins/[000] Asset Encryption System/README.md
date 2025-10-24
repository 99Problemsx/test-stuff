# Asset Encryption System (FPK) - README

## Übersicht

Dieses Plugin bietet ein komplettes Asset-Verschlüsselungs- und Paketierungssystem ähnlich wie Pokémon Flux. Es ermöglicht dir, alle Spiel-Assets (Grafiken, Daten, Audio) in komprimierte `.fpk`-Dateien zu verpacken.

## Features

- ✅ Komprimierung und Verschlüsselung von Graphics, Data und Audio
- ✅ Transparentes Laden (erkennt automatisch Dev/Release-Modus)
- ✅ Signifikante Reduzierung der Dateigröße
- ✅ Schutz der Assets vor einfacher Extraktion
- ✅ JSON-basierter Index für schnellen Dateizugriff
- ✅ XOR-Verschlüsselung mit benutzerdefiniertem Key
- ✅ Debug-Menu Integration

## Installation

1. Das Plugin ist bereits installiert in `Plugins/[000] Asset Encryption System/`
2. **WICHTIG:** Öffne `[002] FPK_Core.rb` und ändere den `ENCRYPTION_KEY`!
3. Starte das Spiel neu, um das Plugin zu laden

## Verwendung

### Während der Entwicklung

Arbeite ganz normal mit deinen Dateien. Das System läuft im **Development Mode** und lädt alle Dateien normal.

### Release Build erstellen

1. Öffne das Debug-Menü (F8)
2. Wähle "Build FPK Packages"
3. Das System erstellt:
   - `Graphics/Assets_0-.fpk` (alle Grafiken)
   - `Data/Data_0-.fpk` (alle Daten)
   - `Audio/Audio_0-.fpk` (alle Audio-Dateien)

### Source-Dateien entfernen (Optional)

⚠️ **VORSICHT!** Dieser Schritt ist nicht rückgängig zu machen!

1. Erstelle ein **Backup** deines Projekts!
2. Teste die `.fpk`-Dateien gründlich!
3. Öffne das Debug-Menü
4. Wähle "Clean FPK Source Files"
5. Bestätige zweimal
6. Die Original-Dateien werden gelöscht

### Release-Struktur

Nach dem Packaging sieht dein Projekt so aus:

```
Graphics/
└── Assets_0-.fpk          ← Alle Grafiken hier drin

Data/
├── Data_0-.fpk            ← Alle Daten hier drin
├── Scripts
└── PluginScripts.rxdata

Audio/
└── Audio_0-.fpk           ← Alle Audio-Dateien hier drin
```

## Technische Details

### Encryption

- **Methode:** XOR-Verschlüsselung
- **Key:** Definiert in `ENCRYPTION_KEY` (BITTE ÄNDERN!)
- **Stärke:** Grundschutz gegen casual modding

### Compression

- **Methode:** Zlib (BEST_COMPRESSION)
- **Ratio:** Typischerweise 40-60% der Originalgröße

### File Format

```
FPK File Structure:
[4 bytes] Magic Header "FPK1"
[4 bytes] Index Size (unsigned long)
[N bytes] Encrypted Index (JSON)
[M bytes] Encrypted + Compressed File Data
```

### Index Format (JSON)

```json
{
  "Graphics/Pokemon/001.png": {
    "offset": 0,
    "size": 12345,
    "original_size": 45678
  },
  ...
}
```

## Debug-Menu Optionen

### Build FPK Packages

Erstellt die verschlüsselten Pakete. Zeigt Statistiken über:

- Anzahl der Dateien
- Original-Größe
- Komprimierte Größe
- Kompressionsverhältnis

### Clean FPK Source Files

⚠️ Löscht die Original-Dateien nach dem Packaging.
Nur für finale Release-Builds verwenden!

### Toggle FPK Mode

Wechselt manuell zwischen Development und Release Mode zum Testen.

## Erweiterte Konfiguration

### Eigene Packages hinzufügen

In `[004] FPK_Builder.rb`, erweitere das `PACKAGES` Hash:

```ruby
PACKAGES = {
  "Graphics/Assets_0-.fpk" => {
    :source => "Graphics",
    :extensions => [".png", ".gif"],
    :exclude => ["Assets_0-.fpk"]
  },
  # Füge hier deine eigenen hinzu
  "MyFolder/MyPackage.fpk" => {
    :source => "MyFolder",
    :extensions => [".dat"],
    :exclude => []
  }
}
```

### Encryption Key ändern

**WICHTIG:** Ändere dies vor dem Release!

In `[002] FPK_Core.rb`:

```ruby
ENCRYPTION_KEY = "DeinGeheimesPasswortHier123!"
```

### Stärkere Verschlüsselung

Für besseren Schutz kannst du die XOR-Verschlüsselung durch AES ersetzen:

1. Installiere eine Ruby-Crypto-Library
2. Ersetze `encrypt()` und `decrypt()` Methoden in `FPK_Core.rb`

## Troubleshooting

### "Invalid FPK file" Fehler

- Die `.fpk`-Datei ist beschädigt
- Der Magic Header stimmt nicht
- **Lösung:** Package neu erstellen

### Dateien werden nicht gefunden

- Pfad-Format überprüfen (forward slashes: `/` statt `\`)
- Index überprüfen (mit `extract_package` debuggen)

### Game startet nicht nach Packaging

- Stelle sicher, dass `Scripts` und `PluginScripts.rxdata` noch existieren
- Diese werden NICHT gepackt!

### Zu große Packages

- Teile große Ordner in mehrere Packages auf
- Passe die `PACKAGES` Konfiguration an

## Performance

- **Erste Ladung:** Minimal langsamer (Index laden)
- **Cached Loads:** Sehr schnell (im RAM gecached)
- **Memory:** Cache kann mit `FPK.clear_cache` geleert werden

## Sicherheit

⚠️ **Hinweise:**

- XOR-Verschlüsselung ist NICHT unknackbar
- Sie bietet Schutz gegen casual modding
- Für maximale Sicherheit: AES oder andere starke Verschlüsselung verwenden
- Source-Code bleibt in `Scripts` lesbar (separate Verschlüsselung nötig)

## Lizenz

Frei verwendbar für deine Projekte. Credits sind willkommen!

## Credits

- **game_guy** - Original JSON Encoder/Decoder
- **DiviBurrito** - JSON Whitespace Support
- **99Problemsx** - FPK System Implementation
- **Pokémon Flux** - Inspiration für das System

## Support

Bei Problemen oder Fragen, erstelle ein Issue auf GitHub oder kontaktiere den Entwickler.

---

**Viel Erfolg mit deinem Release! 🎮**

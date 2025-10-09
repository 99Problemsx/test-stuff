# Pokemon Essentials v21.1 - Custom Build

![Ruby Syntax Check](https://github.com/99Problemsx/test-stuff/actions/workflows/ruby-syntax-check.yml/badge.svg)
![Backup](https://github.com/99Problemsx/test-stuff/actions/workflows/backup.yml/badge.svg)

## 🎮 Über dieses Projekt

Dieses Repository enthält ein vollständiges Pokemon Essentials v21.1 Projekt mit:

- ✅ **v21.1 Hotfixes 1.0.9** (offiziell)
- ✅ **Deluxe Battle Kit (DBK)** - Raid Battles, Dynamax, Z-Moves, Terastallization
- ✅ **Custom Plugins** mit deutschen Übersetzungen
- ✅ **Bugfixes** für bekannte Plugin-Probleme

## 📦 Features

### Hauptfeatures
- **Raid Battles** mit Hotfixes (v1.0.4)
- **Sound Type** Plugin (vollständig funktionsfähig)
- **Deutsche Lokalisierung** mit UTF-8 Support
- **Custom PBS Einträge** für spezielle Pokémon

### Automatisierung
- 🤖 Automatische Releases bei neuen Tags
- 📝 Auto-generiertes Changelog
- 💾 Wöchentliche Backups
- ✅ Ruby Syntax Checks bei jedem Push
- 🏷️ Automatische Issue Labels

## 🚀 Installation

1. **Download**: Lade die neueste Release-Version herunter
2. **Entpacken**: Extrahiere alle Dateien
3. **Spielen**: Starte `Game.exe`

## 📝 Changelog

Siehe [CHANGELOG.md](Plugins/[DBK_003.1]%20Raid%20Battles%20Hotfixes/CHANGELOG.md) für Details zu allen Änderungen.

## 🔧 Entwicklung

### Neue Version erstellen

```bash
# Tag erstellen und pushen
git tag v1.0.5
git push origin v1.0.5

# Automatisch wird ein Release mit ZIP erstellt!
```

### Manuelles Backup triggern

Gehe zu: Actions → Backup Project → Run workflow

### Syntax Check ausführen

```bash
# Lokal testen
ruby -c Plugins/**/*.rb
```

## 📊 Status

- **Ruby Version**: 3.1+
- **Essentials Version**: v21.1
- **Hotfixes Version**: 1.0.4
- **Letztes Update**: Automatisch über GitHub Actions

## 🤝 Beiträge

Dieses ist ein privates Projekt. Issues und Pull Requests sind willkommen!

## 📄 Lizenz

Pokemon Essentials - Siehe [pokemoncommunity.com](https://www.pokemoncommunity.com/)

---

**Hinweis**: Dieses Repository nutzt GitHub Actions für automatische Workflows. Alle Workflows sind im `.github/workflows/` Ordner zu finden.

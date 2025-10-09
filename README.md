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
- 🤖 **Automatische Releases** bei neuen Tags (inkl. ZIP-Erstellung)
- 📝 **Auto-generiertes Changelog** aus Commits
- 💾 **Wöchentliche Backups** (jeden Sonntag, 90 Tage Aufbewahrung)
- ✅ **Ruby Syntax Checks** bei jedem Push zu Plugins
- 🏷️ **Automatische Issue Labels** basierend auf Keywords
- 📊 **Download Statistiken** (täglich aktualisiert)
- 🔍 **Code Quality Analysis** (RuboCop, Flog, Flay)
- 📚 **Auto-Dokumentation** für Plugins und PBS Files
- 🧪 **Plugin Load Order Testing**
- ✉️ **Discord/Slack Benachrichtigungen** (optional)
- ✔️ **PBS File Validation** (UTF-8, BOM, Encoding)

## 🚀 Installation

1. **Download**: Lade die neueste Release-Version herunter
2. **Entpacken**: Extrahiere alle Dateien
3. **Spielen**: Starte `Game.exe`

## 📝 Changelog

Siehe [CHANGELOG.md](Plugins/[DBK_003.1]%20Raid%20Battles%20Hotfixes/CHANGELOG.md) für Details zu allen Änderungen.

## 🔧 Entwicklung

### Discord/Slack Notifications einrichten

Siehe [AUTOMATION_SETUP.md](AUTOMATION_SETUP.md) für detaillierte Anweisungen!

**Kurzversion:**
1. Erstelle Discord Webhook oder Slack Webhook
2. Füge als GitHub Secret hinzu (`DISCORD_WEBHOOK` oder `SLACK_WEBHOOK`)
3. Fertig! Benachrichtigungen laufen automatisch

### Neue Version erstellen

```bash
# Tag erstellen und pushen
git tag v1.0.5
git push origin v1.0.5

# Automatisch wird ein Release mit ZIP erstellt!
```

### Manuelles Backup triggern

Gehe zu: Actions → Backup Project → Run workflow

### Dokumentation generieren

```bash
# Manuell triggern
Gehe zu: Actions → Generate Documentation → Run workflow

# Automatisch generiert:
# - PLUGINS.md (Plugin-Übersicht)
# - PBS_DOCS.md (PBS-Datei Dokumentation)
# - PROJECT_OVERVIEW.md (Projekt-Statistiken)
```

### Code Quality prüfen

```bash
# Läuft automatisch wöchentlich
# Manuell starten: Actions → Code Quality Analysis → Run workflow

# Reports werden als Artifacts gespeichert:
# - rubocop-report.json (Style Check)
# - flog-report.txt (Complexity Analysis)
# - flay-report.txt (Code Duplication)
# - code-stats.md (Statistics)
```

### Syntax Check ausführen

```bash
# Lokal testen
ruby -c Plugins/**/*.rb
```

## 📊 Status

![Ruby Syntax Check](https://github.com/99Problemsx/test-stuff/actions/workflows/ruby-syntax-check.yml/badge.svg)
![PBS Validation](https://github.com/99Problemsx/test-stuff/actions/workflows/validate-pbs.yml/badge.svg)
![Plugin Tests](https://github.com/99Problemsx/test-stuff/actions/workflows/test-plugins.yml/badge.svg)
![Code Quality](https://github.com/99Problemsx/test-stuff/actions/workflows/code-quality.yml/badge.svg)
![Backup](https://github.com/99Problemsx/test-stuff/actions/workflows/backup.yml/badge.svg)

- **Ruby Version**: 3.1+
- **Essentials Version**: v21.1
- **Hotfixes Version**: 1.0.4
- **Letztes Update**: Automatisch über GitHub Actions
- **Download Stats**: Siehe [STATS.md](STATS.md)

## 🤝 Beiträge

Dieses ist ein privates Projekt. Issues und Pull Requests sind willkommen!

## 📄 Lizenz

Pokemon Essentials - Siehe [pokemoncommunity.com](https://www.pokemoncommunity.com/)

---

**Hinweis**: Dieses Repository nutzt GitHub Actions für automatische Workflows. 

- 📖 **Setup Guide**: [AUTOMATION_SETUP.md](AUTOMATION_SETUP.md)
- 📊 **Download Stats**: [STATS.md](STATS.md) (wird täglich aktualisiert)
- 📚 **Plugin Docs**: [PLUGINS.md](PLUGINS.md) (auto-generiert)
- 📝 **PBS Docs**: [PBS_DOCS.md](PBS_DOCS.md) (auto-generiert)
- 📈 **Project Overview**: [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md)

Alle Workflows findest du im [`.github/workflows/`](.github/workflows/) Ordner.

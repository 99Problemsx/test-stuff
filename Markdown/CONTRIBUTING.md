# Contributing Guidelines

Danke, dass du zu diesem Pokemon Essentials Projekt beitragen möchtest! 🎮

## 🚀 Quick Start

1. **Fork** das Repository
2. **Clone** deinen Fork: `git clone https://github.com/DEIN_USERNAME/test-stuff.git`
3. **Branch** erstellen: `git checkout -b feature/deine-feature`
4. **Änderungen** machen und committen
5. **Push** zu deinem Fork: `git push origin feature/deine-feature`
6. **Pull Request** erstellen

## 📝 Commit Messages

Wir verwenden [Conventional Commits](https://www.conventionalcommits.org/):

### Format
```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types
- `feat:` - Neues Feature
- `fix:` - Bugfix
- `docs:` - Dokumentation
- `style:` - Code-Formatierung (kein funktionaler Code)
- `refactor:` - Code-Refactoring
- `perf:` - Performance-Verbesserung
- `test:` - Tests hinzufügen/ändern
- `chore:` - Build-Tasks, Dependencies, etc.
- `ci:` - CI/CD Änderungen

### Scope (optional)
- `plugin` - Plugin-bezogen
- `pbs` - PBS-Dateien
- `battle` - Battle-System
- `raids` - Raid Battles
- `ui` - User Interface
- `docs` - Dokumentation

### Beispiele
```bash
feat(plugin): Add new Sound type effectiveness
fix(raids): Fix Ditto using Struggle in raids
docs(readme): Update installation instructions
ci(workflow): Add performance testing
```

## 🐛 Bug Reports

Verwende das Issue-Template und gib folgende Infos an:

- **Beschreibung**: Was ist das Problem?
- **Schritte zum Reproduzieren**: Wie kann man den Bug nachstellen?
- **Erwartetes Verhalten**: Was sollte passieren?
- **Screenshots**: Falls hilfreich
- **Environment**: 
  - Essentials Version
  - Plugin Versionen
  - Ruby Version (falls bekannt)

## ✨ Feature Requests

- Beschreibe das Feature detailliert
- Erkläre, warum es nützlich wäre
- Gib Beispiele, wie es funktionieren sollte

## 🔧 Code Guidelines

### Ruby
- Ruby 3.1+ Syntax verwenden
- Einrückung: 2 Spaces
- Keine Tabs
- UTF-8 Encoding für deutsche Umlaute

### Plugins
- Jedes Plugin braucht `meta.txt`
- `meta.txt` Pflichtfelder:
  - `Name`
  - `Version`
  - `Author`
- Dependencies in `Requires` angeben

### PBS Files
- **Immer UTF-8 ohne BOM**
- Keine Windows-1252 Encoding
- Deutsche Umlaute sind OK (ä, ö, ü, ß)

## 🧪 Testing

Vor dem PR:

1. Ruby Syntax Check:
```bash
ruby -c deine_datei.rb
```

2. Teste im Spiel:
- Starte das Spiel
- Teste deine Änderungen
- Prüfe auf Fehler

3. PBS Validierung (automatisch im CI)

## 📋 Pull Request Process

1. **Branch benennen**: `feature/xyz` oder `fix/xyz`
2. **Commits**: Verwende Conventional Commits
3. **Beschreibung**: Erkläre was und warum
4. **Tests**: Stelle sicher, dass alles funktioniert
5. **CI**: Warte auf grüne Checks
6. **Review**: Reagiere auf Feedback

### PR Template
```markdown
## Beschreibung
Was macht dieser PR?

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation

## Testing
Wie wurde getestet?

## Screenshots
Falls UI-Änderungen
```

## 🎯 Plugin Development

### Plugin Struktur
```
Plugins/
  [Your Plugin]/
    meta.txt
    001_Main.rb
    002_Battle.rb
    README.md (optional)
    CHANGELOG.md (optional)
```

### meta.txt Beispiel
```
Name         = My Plugin
Version      = 1.0.0
Author       = Your Name
Link         = https://github.com/...
Requires     = [DBK] Raid Battles,1.0
```

### Code Style
```ruby
# encoding: UTF-8

# Klassen in PascalCase
class MyPlugin
  # Methoden in snake_case
  def my_method(param)
    # 2 spaces Einrückung
    return param.upcase
  end
end
```

## 🔍 Code Review

Reviewer achten auf:

- ✅ Code funktioniert
- ✅ Folgt Style Guidelines
- ✅ Keine Syntax-Fehler
- ✅ Dokumentation aktualisiert
- ✅ Tests bestanden (CI)
- ✅ Keine Secrets/Passwörter im Code

## 📚 Ressourcen

- [Pokemon Essentials Wiki](https://essentialsdocs.fandom.com/)
- [Ruby Docs](https://ruby-doc.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)

## ❓ Fragen?

- Erstelle ein Issue mit Label `question`
- Oder schau in bestehende Issues/PRs

## 🎉 Credits

Alle Contributors werden in der README erwähnt!

---

**Vielen Dank für deinen Beitrag! 🚀**

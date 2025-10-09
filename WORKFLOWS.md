# 🎯 Workflow Overview

## 📊 Alle GitHub Actions Workflows

### 🚀 Release & Deployment

#### Create Release (`create-release.yml`)
- **Trigger**: Tag push (v*)
- **Funktion**: Erstellt automatisch ein GitHub Release mit:
  - ZIP-Archiv des kompletten Projekts
  - Release Notes aus Commits
  - Automatischer Download-Counter

#### Deploy GitHub Pages (`deploy-pages.yml`)
- **Trigger**: Push to main, Manual
- **Funktion**: Deployed die Dokumentation auf GitHub Pages
- **URL**: https://99problemsx.github.io/test-stuff/

#### Semantic Release (`semantic-release.yml`)
- **Trigger**: Push to main
- **Funktion**: Automatische Versionierung basierend auf Conventional Commits
  - `fix:` → Patch (v1.0.x)
  - `feat:` → Minor (v1.x.0)
  - `BREAKING CHANGE:` → Major (vx.0.0)

---

### ✅ Quality Assurance

#### Ruby Syntax Check (`ruby-syntax-check.yml`)
- **Trigger**: Push/PR zu Plugins/**
- **Funktion**: Prüft Ruby-Syntax aller Plugin-Dateien
- **Tools**: `ruby -c`

#### Code Quality Analysis (`code-quality.yml`)
- **Trigger**: Wöchentlich (Montag), Manual
- **Funktion**: Analysiert Code-Qualität mit:
  - **RuboCop**: Style Check & Linting
  - **Flog**: Complexity Analysis
  - **Flay**: Code Duplication Detection
- **Output**: JSON Reports als Artifacts

#### Validate PBS Files (`validate-pbs.yml`)
- **Trigger**: Push/PR zu PBS/**
- **Funktion**: Validiert PBS-Dateien:
  - UTF-8 Encoding
  - BOM Check
  - Syntax Validation

#### Test Plugins (`test-plugins.yml`)
- **Trigger**: Push/PR, Manual
- **Funktion**: Testet Plugin Load Order und Dependencies

#### Performance Test (`performance-test.yml`)
- **Trigger**: Push to main, Manual
- **Funktion**: Benchmark Tests für kritische Funktionen

---

### 🔒 Security & Maintenance

#### Security Scan (`security-scan.yml`)
- **Trigger**: Push/PR, Wöchentlich, Manual
- **Funktion**: Scannt nach Sicherheitslücken:
  - **Trivy**: Vulnerability Scanner
  - **TruffleHog**: Secret Detection
- **SARIF Upload**: Automatisch zu GitHub Security

#### Dependabot Auto-Merge (`dependabot-auto-merge.yml`)
- **Trigger**: Dependabot PR
- **Funktion**: Automatisches Approve & Merge von:
  - Patch Updates (v1.0.x)
  - Minor Updates (v1.x.0)
- **Major Updates**: Manuelle Review erforderlich

#### Backup Project (`backup.yml`)
- **Trigger**: Wöchentlich (Sonntag 00:00 UTC), Manual
- **Funktion**: Erstellt vollständiges Backup
- **Retention**: 90 Tage

#### Stale Bot (`stale.yml`)
- **Trigger**: Täglich
- **Funktion**: Markiert & schließt inaktive Issues/PRs
  - 60 Tage Inaktivität → "stale" Label
  - 7 Tage nach Label → Auto-Close

---

### 📚 Documentation

#### Generate Documentation (`generate-docs.yml`)
- **Trigger**: Push to main, Manual
- **Funktion**: Generiert automatisch:
  - `PLUGINS.md`: Plugin Inventory
  - `PBS_DOCS.md`: PBS Files Documentation
  - `PROJECT_OVERVIEW.md`: Projekt Statistiken

#### Update Changelog (`update-changelog.yml`)
- **Trigger**: Push to main, Manual
- **Funktion**: Generiert `CHANGELOG_AUTO.md` aus Commit History

#### Track Downloads (`track-downloads.yml`)
- **Trigger**: Täglich (00:00 UTC), Manual
- **Funktion**: Tracked Download-Statistiken aller Releases
- **Output**: `STATS.md`

---

### 🔔 Notifications

#### Discord Notifications (`discord-notifications.yml`)
- **Trigger**: Push to main, Release, PR
- **Funktion**: Sendet Webhook-Benachrichtigungen an Discord
- **Setup**: `DISCORD_WEBHOOK` Secret erforderlich

---

### 🏷️ Automation

#### Auto Label Issues (`auto-label.yml`)
- **Trigger**: PR opened/edited
- **Funktion**: Labelt PRs automatisch basierend auf:
  - Geänderten Dateipfaden (ci/cd, plugins, docs, etc.)
  - Dependabot PRs (dependencies, github_actions)

---

## 📈 Workflow Statistics

**Gesamt**: 17 aktive Workflows
**Automatisch**: 14 Workflows (82%)
**Manual Trigger**: 15 Workflows (88%)
**Scheduled**: 4 Workflows (24%)

---

## 🔧 Workflows manuell triggern

1. Gehe zu: **Actions** Tab
2. Wähle den gewünschten Workflow
3. Klicke **Run workflow**
4. Wähle Branch (meist `main`)
5. Klicke **Run workflow** Button

---

## ⚙️ Setup & Configuration

### Discord Notifications
```bash
# 1. Discord Webhook erstellen (Server Settings → Integrations → Webhooks)
# 2. Als Secret hinzufügen:
gh secret set DISCORD_WEBHOOK --body "https://discord.com/api/webhooks/..."
```

### Branch Protection
```bash
# Bereits aktiviert für main branch:
# - Keine Force Pushes
# - Keine Branch Deletion
# - Auto-Merge erlaubt
```

### Dependabot
```yaml
# .github/dependabot.yml
# Automatisch aktiv für:
# - GitHub Actions (wöchentlich)
# - Auto-Merge für Patch/Minor Updates
```

---

## 📊 Badge URLs

Alle Workflows haben Status Badges:

```markdown
![Workflow Name](https://github.com/99Problemsx/test-stuff/actions/workflows/WORKFLOW_FILE.yml/badge.svg)
```

Siehe [README.md](../README.md) für aktuelle Badges!

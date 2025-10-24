# Automation Setup Guide

Diese Datei erklärt, wie du alle Automation-Features aktivierst.

## 📋 Inhaltsverzeichnis

- [Discord Benachrichtigungen](#discord-benachrichtigungen)
- [Slack Benachrichtigungen](#slack-benachrichtigungen)
- [GitHub Secrets einrichten](#github-secrets-einrichten)
- [Workflows aktivieren](#workflows-aktivieren)

---

## 🎮 Discord Benachrichtigungen

### Schritt 1: Discord Webhook erstellen

1. Öffne deinen Discord Server
2. Gehe zu **Server Settings** → **Integrations** → **Webhooks**
3. Klicke auf **New Webhook**
4. Gib einen Namen ein (z.B. "GitHub Bot")
5. Wähle den Kanal aus, wo Benachrichtigungen erscheinen sollen
6. Kopiere die **Webhook URL**

### Schritt 2: Webhook in GitHub hinzufügen

1. Gehe zu deinem Repository: https://github.com/99Problemsx/test-stuff
2. Klicke auf **Settings** → **Secrets and variables** → **Actions**
3. Klicke auf **New repository secret**
4. Name: `DISCORD_WEBHOOK`
5. Value: Füge deine Discord Webhook URL ein
6. Klicke **Add secret**

✅ Fertig! Jetzt bekommst du Discord-Benachrichtigungen für:
- Neue Commits
- Releases
- Issues
- Pull Requests

---

## 💬 Slack Benachrichtigungen

### Schritt 1: Slack Webhook erstellen

1. Gehe zu: https://api.slack.com/apps
2. Klicke **Create New App** → **From scratch**
3. App Name: "GitHub Notifications"
4. Wähle deinen Workspace
5. Gehe zu **Incoming Webhooks**
6. Aktiviere **Activate Incoming Webhooks**
7. Klicke **Add New Webhook to Workspace**
8. Wähle den Kanal aus
9. Kopiere die **Webhook URL**

### Schritt 2: Webhook in GitHub hinzufügen

1. Gehe zu **Settings** → **Secrets and variables** → **Actions**
2. **New repository secret**
3. Name: `SLACK_WEBHOOK`
4. Value: Deine Slack Webhook URL
5. **Add secret**

---

## 🔐 GitHub Secrets Übersicht

Hier sind alle Secrets, die du einrichten kannst:

| Secret Name | Erforderlich? | Wofür? |
|------------|---------------|--------|
| `DISCORD_WEBHOOK` | Optional | Discord Benachrichtigungen |
| `SLACK_WEBHOOK` | Optional | Slack Benachrichtigungen |
| `GITHUB_TOKEN` | ✅ Automatisch | Automatisch von GitHub erstellt |

**Hinweis**: `GITHUB_TOKEN` wird automatisch von GitHub bereitgestellt, du musst nichts tun!

---

## 🚀 Workflows aktivieren

Alle Workflows sind bereits im Repository und funktionieren automatisch!

### Automatische Workflows

Diese laufen automatisch:

1. **Ruby Syntax Check** - Bei jedem Push zu Plugins
2. **PBS Validation** - Bei Änderungen an PBS Dateien
3. **Plugin Tests** - Bei Plugin-Änderungen
4. **Auto-Label Issues** - Bei neuen Issues
5. **Weekly Backup** - Jeden Sonntag um 2 Uhr
6. **Download Stats** - Täglich um Mitternacht
7. **Code Quality** - Wöchentlich am Sonntag

### Manuelle Workflows

Diese kannst du manuell starten:

1. Gehe zu: https://github.com/99Problemsx/test-stuff/actions
2. Wähle einen Workflow aus der Liste
3. Klicke **Run workflow**

**Verfügbare manuelle Workflows**:
- Backup Project (Backup jetzt erstellen)
- Track Downloads (Stats sofort aktualisieren)
- Generate Documentation (Doku neu generieren)
- Update Changelog (Changelog aktualisieren)

---

## 📦 Release erstellen

So erstellst du einen neuen Release mit automatischer ZIP-Datei:

```bash
# Lokales Repository
cd "C:\Users\Marcel Weidenauer\Documents\GitHub\Backup_Clean_2025-10-03_23-49"

# Tag erstellen
git tag v1.0.5

# Tag pushen
git push origin v1.0.5
```

**Das passiert automatisch:**
1. ✅ ZIP-Datei wird erstellt
2. ✅ GitHub Release wird erstellt
3. ✅ Discord/Slack Benachrichtigung (falls konfiguriert)
4. ✅ Download Stats werden aktualisiert

---

## 🎯 Workflow Status anzeigen

Badge in README.md anzeigen:

```markdown
![Ruby Syntax Check](https://github.com/99Problemsx/test-stuff/actions/workflows/ruby-syntax-check.yml/badge.svg)
```

Alle Workflows anzeigen:
https://github.com/99Problemsx/test-stuff/actions

---

## 🐛 Troubleshooting

### Workflow läuft nicht

1. Prüfe ob der Workflow aktiviert ist: Settings → Actions → General
2. Stelle sicher, dass "Allow all actions" aktiviert ist

### Discord/Slack Benachrichtigungen funktionieren nicht

1. Prüfe ob das Secret korrekt eingetragen ist
2. Teste die Webhook URL in Postman oder curl
3. Prüfe die Workflow-Logs in GitHub Actions

### Badge zeigt "unknown"

1. Workflow muss mindestens 1x gelaufen sein
2. Repository muss public sein (oder Badge-Token verwenden)

---

## 📚 Weitere Ressourcen

- [GitHub Actions Dokumentation](https://docs.github.com/en/actions)
- [Discord Webhooks](https://discord.com/developers/docs/resources/webhook)
- [Slack Webhooks](https://api.slack.com/messaging/webhooks)

---

**Fragen?** Erstelle ein Issue im Repository!

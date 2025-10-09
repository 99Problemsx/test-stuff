# ❓ Frequently Asked Questions

Common questions and answers about Pokemon Essentials v21.1.

---

## 🎮 Gameplay

### What version of Pokemon Essentials is this?
**v21.1** with official Hotfixes **1.0.9**.

### What features are included?
- Deluxe Battle Kit (Raid Battles, Dynamax, Z-Moves, Terastallization)
- Sound Type (custom type)
- German localization
- 50+ custom plugins

See **[Gameplay Features](Gameplay-Features)** for complete list.

### Can I play this in English?
Currently only German is fully supported. English translation is planned.

### Where are save files stored?
In the game folder: `Game_*.rxdata`

**Tip**: Backup these files regularly!

### How do I transfer saves between versions?
1. Copy `Game_*.rxdata` from old version
2. Paste into new version folder
3. Start game normally

---

## 🔧 Technical

### What are the system requirements?
**Minimum**:
- Windows 7+
- 2 GB RAM
- 500 MB storage

**Recommended**:
- Windows 10/11
- 4 GB RAM
- 1 GB storage

### Does it work on Mac/Linux?
Not officially, but you can try:
- **Mac**: Use Wine or Parallels
- **Linux**: Use Wine or PlayOnLinux

### Why does Windows Defender flag the game?
False positive. The game is safe. This happens with RGSS games because:
- No digital signature
- Unpopular executable format

**Solution**: Add exception in Windows Defender.

### Can I play offline?
Yes! No internet connection required.

### How do I update the game?
1. Download new version
2. Backup save files
3. Extract new version
4. Copy save files back

See **[Installation Guide](Installation-Guide#-updating-to-new-version)** for details.

---

## 🐛 Troubleshooting

### Game crashes on startup
**Try these solutions**:
1. Run as Administrator
2. Install [VC++ Redistributable](https://aka.ms/vs/17/release/vc_redist.x86.exe)
3. Extract ALL files from ZIP
4. Update graphics drivers

### Black screen when starting
1. Update graphics drivers
2. Run in compatibility mode (Windows 7)
3. Disable fullscreen optimizations

### Save file won't load
1. Navigate to game folder
2. Delete `Save*.rxdata` files
3. Start new game

**Note**: Your save may be corrupted. Always keep backups!

### Missing DLL errors
Extract **all files** from the ZIP, not just `Game.exe`.

Required files:
- `Game.exe`
- `RGSS104E.dll`
- `Data/` folder
- `Graphics/` folder
- `Audio/` folder
- All `.dll` files

---

## 🔌 Plugins

### What plugins are included?
See **[Plugin System](Plugin-System)** for complete list.

### Can I add my own plugins?
Yes! Place them in `Plugins/` folder.

**Requirements**:
- Ruby file (`.rb`)
- Compatible with v21.1
- Proper metadata comments

### How do I disable a plugin?
1. Navigate to `Plugins/` folder
2. Rename plugin file: `plugin.rb` → `plugin.rb.disabled`
3. Restart game

### Are plugins updated automatically?
No, manual update required. Check our **[Releases](https://github.com/99Problemsx/test-stuff/releases)**.

---

## 🛠️ Development

### Can I contribute?
Yes! See **[Contributing Guide](Contributing)**.

### How do I report bugs?
1. Check existing **[Issues](https://github.com/99Problemsx/test-stuff/issues)**
2. Create new issue with:
   - Clear title
   - Steps to reproduce
   - Screenshots/error messages
   - System info

### How do I suggest features?
Open an **[Issue](https://github.com/99Problemsx/test-stuff/issues/new)** with label "enhancement".

### What IDE do you recommend?
- **VS Code** (recommended)
- RubyMine
- Sublime Text
- Notepad++

### How does CI/CD work?
See **[CI/CD Pipeline](CI-CD-Pipeline)** documentation.

---

## 📦 Releases

### How often are releases?
- **Hotfixes**: As needed (critical bugs)
- **Minor updates**: Monthly
- **Major updates**: Quarterly

Follow **[Releases](https://github.com/99Problemsx/test-stuff/releases)** for notifications.

### What's the difference between versions?
We use **[Semantic Versioning](https://semver.org/)**:
- `v1.0.X` - Patch (bug fixes)
- `v1.X.0` - Minor (new features)
- `vX.0.0` - Major (breaking changes)

### Where can I download old versions?
All versions available at **[Releases](https://github.com/99Problemsx/test-stuff/releases)**.

### How are releases created?
Automatically via GitHub Actions when we push a tag:
```bash
git tag v1.0.5
git push origin v1.0.5
```

---

## 🌐 Community

### Is there a Discord server?
Not yet, but planned! Check **[Discussions](https://github.com/99Problemsx/test-stuff/discussions)**.

### How can I help?
- Report bugs
- Suggest features
- Contribute code
- Improve documentation
- Share the project

### Can I use this in my project?
Check Pokemon Essentials license at **[PokéCommunity](https://www.pokemoncommunity.com/)**.

---

## 📄 Legal

### Is this official Pokemon?
No. This is a fan-made project using Pokemon Essentials.

### Can I monetize this?
**No.** Pokemon is a trademark of Nintendo/Game Freak.

### Are you affiliated with Nintendo?
**No.** This is an independent fan project.

### Can I distribute this?
Link to our **[Releases](https://github.com/99Problemsx/test-stuff/releases)** page. Don't re-upload.

---

## 🔄 Updates & Changelogs

### Where can I see what changed?
- **[CHANGELOG_AUTO.md](https://github.com/99Problemsx/test-stuff/blob/main/CHANGELOG_AUTO.md)** - Auto-generated
- **[Release Notes](https://github.com/99Problemsx/test-stuff/releases)** - Manual summaries

### How do I know about new releases?
1. **Watch** the repository (top right on GitHub)
2. Choose "Releases only"
3. Get email notifications

Or follow via **[RSS](https://github.com/99Problemsx/test-stuff/releases.atom)**.

---

## 🎯 Performance

### Game runs slowly
**Try these**:
1. Close other programs
2. Update graphics drivers
3. Run in windowed mode
4. Disable unused plugins

### High CPU usage
Normal for RGSS games. Try:
1. Lower priority in Task Manager
2. Disable background apps
3. Check for malware

### Large file size
Pokemon Essentials games are 300-500 MB due to:
- Graphics (sprites, tilesets)
- Audio (music, sound effects)
- Game data (PBS files)

---

## 🆘 Still Need Help?

Can't find your answer?

1. Check **[Troubleshooting](Troubleshooting)** guide
2. Search **[Issues](https://github.com/99Problemsx/test-stuff/issues)**
3. Create new issue
4. Join **[Discussions](https://github.com/99Problemsx/test-stuff/discussions)**

---

## 📝 Contributing to FAQ

Found a question that should be here?
1. Open an **[Issue](https://github.com/99Problemsx/test-stuff/issues/new)**
2. Label it "documentation"
3. Suggest the Q&A

---

[⬅ Back to Home](Home) | [➡ Next: Troubleshooting](Troubleshooting)

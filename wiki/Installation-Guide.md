# 📥 Installation Guide

Complete guide to download, install, and run Pokemon Essentials v21.1.

---

## 📋 Requirements

### Minimum Requirements
- **OS**: Windows 7 or later
- **RAM**: 2 GB
- **Storage**: 500 MB free space
- **Graphics**: DirectX 9.0c compatible

### Recommended Requirements
- **OS**: Windows 10/11
- **RAM**: 4 GB
- **Storage**: 1 GB free space
- **Graphics**: Modern GPU with DirectX 11

---

## 🚀 Installation Steps

### Step 1: Download

1. Go to the **[Releases page](https://github.com/99Problemsx/test-stuff/releases/latest)**
2. Download the latest `Pokemon-Essentials-vX.X.X.zip` file
3. Wait for the download to complete

![Download Release](https://via.placeholder.com/800x200/4CAF50/FFFFFF?text=Download+the+Latest+Release)

### Step 2: Extract

1. **Right-click** on the downloaded ZIP file
2. Select **"Extract All..."** (Windows) or use your favorite extraction tool
3. Choose a destination folder (e.g., `C:\Games\Pokemon-Essentials\`)
4. Click **"Extract"**

> ⚠️ **Important**: Extract to a folder where you have write permissions!

### Step 3: Run

1. Navigate to the extracted folder
2. Find **`Game.exe`**
3. **Double-click** to start the game
4. Enjoy! 🎮

---

## 🔧 Configuration

### Graphics Settings

The game runs in windowed mode by default. To change settings:

1. Press **F1** while in-game (if supported)
2. Or edit `Game.ini`:
   ```ini
   [Game]
   Title=Pokemon Essentials
   Scripts=Data/Scripts.rxdata
   RTP1=
   RTP2=
   RTP3=
   Library=RGSS104E.dll
   ```

### Save Files

Save files are stored in:
```
[Game Folder]/
```

To backup your saves, copy all files matching `Game_*.rxdata`

---

## 🐛 Troubleshooting

### Game won't start

**Problem**: Double-clicking `Game.exe` does nothing

**Solutions**:
1. Right-click `Game.exe` → **"Run as Administrator"**
2. Check if `RGSS104E.dll` exists in the same folder
3. Install [Visual C++ Redistributable](https://aka.ms/vs/17/release/vc_redist.x86.exe)

### Missing DLL errors

**Problem**: Error message about missing DLL files

**Solutions**:
1. Extract **all files** from the ZIP (not just Game.exe)
2. Install missing Visual C++ Redistributables
3. Re-download the release (file might be corrupted)

### Black screen on start

**Problem**: Game opens but shows only black screen

**Solutions**:
1. Update your graphics drivers
2. Try running in **compatibility mode** (Windows 7)
3. Disable fullscreen optimizations:
   - Right-click `Game.exe` → Properties
   - Compatibility tab → ☑ Disable fullscreen optimizations

### Save file corruption

**Problem**: Game crashes when loading save

**Solutions**:
1. Navigate to the game folder
2. Delete files matching `Save*.rxdata`
3. Start a new game

> 💡 **Tip**: Make regular backups of your save files!

---

## 🔄 Updating to New Version

### Method 1: Clean Install (Recommended)

1. **Backup your save files** (`Game_*.rxdata`)
2. Delete the old game folder
3. Download and extract the new version
4. Copy your save files to the new folder

### Method 2: Overwrite

> ⚠️ **Not recommended** - May cause conflicts

1. Download the new version
2. Extract to the **same folder**
3. Choose **"Replace all"** when prompted

---

## 📦 Portable Installation

Want to run from USB drive?

1. Extract the game to your USB drive
2. No installation needed - just run `Game.exe`
3. Save files will be on the USB drive

> 💡 **Tip**: Use a USB 3.0+ drive for best performance!

---

## 🌐 Network Requirements

This game **does not require** an internet connection to play.

However, you need internet to:
- Download updates
- Check for new releases
- Report bugs

---

## ✅ Installation Checklist

- [ ] Downloaded latest release
- [ ] Extracted all files
- [ ] Can run `Game.exe`
- [ ] Backed up save files (if updating)
- [ ] Read troubleshooting guide

---

## 🆘 Still Having Issues?

1. Check the **[Troubleshooting](Troubleshooting)** page
2. Search existing **[Issues](https://github.com/99Problemsx/test-stuff/issues)**
3. Create a new issue with:
   - Your Windows version
   - Error message (screenshot)
   - Steps to reproduce

---

## 📝 Next Steps

After installation:
- Read the **[Gameplay Features](Gameplay-Features)** guide
- Check out **[FAQ](FAQ)** for common questions
- Join our community discussions!

---

[⬅ Back to Home](Home) | [➡ Next: Gameplay Features](Gameplay-Features)

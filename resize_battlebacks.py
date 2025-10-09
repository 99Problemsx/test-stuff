"""
Resize all battle background images to 512x384 pixels
"""

from PIL import Image
import os
from pathlib import Path

# Konfiguration
BATTLEBACKS_DIR = "Graphics/Battlebacks"
TARGET_WIDTH = 512
TARGET_HEIGHT = 384

def resize_battleback(image_path):
    """Resize a battle background image to 512x384 pixels"""
    try:
        # Öffne das Bild
        img = Image.open(image_path)
        original_size = img.size
        
        # Wenn bereits die richtige Größe, überspringe
        if img.size == (TARGET_WIDTH, TARGET_HEIGHT):
            print(f"✓ Bereits korrekt: {image_path.name}")
            return
        
        # Berechne Skalierung (aspect ratio beibehalten)
        img_ratio = img.width / img.height
        target_ratio = TARGET_WIDTH / TARGET_HEIGHT
        
        if img_ratio > target_ratio:
            # Bild ist breiter -> an Höhe anpassen
            new_height = TARGET_HEIGHT
            new_width = int(new_height * img_ratio)
        else:
            # Bild ist höher -> an Breite anpassen
            new_width = TARGET_WIDTH
            new_height = int(new_width / img_ratio)
        
        # Skaliere das Bild
        img_resized = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
        
        # Erstelle neues Bild mit Zielgröße
        new_img = Image.new('RGBA', (TARGET_WIDTH, TARGET_HEIGHT), (0, 0, 0, 0))
        
        # Zentriere das skalierte Bild
        paste_x = (TARGET_WIDTH - new_width) // 2
        paste_y = (TARGET_HEIGHT - new_height) // 2
        
        # Wenn das Bild größer ist als die Zielgröße, schneide es zu
        if new_width > TARGET_WIDTH or new_height > TARGET_HEIGHT:
            crop_x = (new_width - TARGET_WIDTH) // 2 if new_width > TARGET_WIDTH else 0
            crop_y = (new_height - TARGET_HEIGHT) // 2 if new_height > TARGET_HEIGHT else 0
            img_resized = img_resized.crop((
                crop_x,
                crop_y,
                crop_x + TARGET_WIDTH,
                crop_y + TARGET_HEIGHT
            ))
            paste_x = 0
            paste_y = 0
        
        # Füge das Bild ein
        if img_resized.mode == 'RGBA':
            new_img.paste(img_resized, (paste_x, paste_y), img_resized)
        else:
            new_img.paste(img_resized, (paste_x, paste_y))
        
        # Speichere das Bild
        new_img.save(image_path, 'PNG')
        print(f"✓ Angepasst: {image_path.name} ({original_size[0]}x{original_size[1]} → {TARGET_WIDTH}x{TARGET_HEIGHT})")
        
    except Exception as e:
        print(f"✗ Fehler bei {image_path.name}: {e}")

def main():
    battlebacks_path = Path(BATTLEBACKS_DIR)
    
    if not battlebacks_path.exists():
        print(f"Fehler: Verzeichnis '{BATTLEBACKS_DIR}' nicht gefunden!")
        return
    
    # Finde alle _bg.png Dateien
    bg_files = list(battlebacks_path.glob("*_bg.png"))
    
    if not bg_files:
        print("Keine _bg.png Dateien gefunden!")
        return
    
    print(f"Gefunden: {len(bg_files)} Battle Background Dateien\n")
    print("Starte Anpassung auf 512x384 Pixel...\n")
    
    # Verarbeite jede Datei
    for bg_file in sorted(bg_files):
        resize_battleback(bg_file)
    
    print(f"\n✓ Fertig! {len(bg_files)} Dateien verarbeitet.")

if __name__ == "__main__":
    main()

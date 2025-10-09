# ============================================================================
# BitmapLoader - DEAKTIVIERT - Verwende stattdessen 001b_RPG_Cache_Override
# ============================================================================
# BitmapWrapper.initialize Override funktioniert nicht in RGSS wegen
# C-Extension File-Access Probleme
# ============================================================================

# DEAKTIVIERT
if false && defined?(GameLoader) && defined?(BitmapWrapper)
  class BitmapWrapper < Bitmap
    # Class variables für temp file management
    @@temp_counter = 0
    @@loaded_from_pack = 0
    @@load_log = []
    
    # Speichere die originale initialize Methode
    alias_method :bitmap_initialize_original, :initialize
    
    # Überschreibe initialize
    def initialize(*args)
      # Wenn ein String-Argument (Dateipfad) übergeben wird
      if args.length >= 1 && args[0].is_a?(String)
        path = args[0]
        
        # DEBUG - Log ersten 20 Aufrufe
        @@temp_counter += 1
        if @@temp_counter <= 20
          @@load_log << "#{@@temp_counter}. BitmapLoader: #{path.inspect}"
          
          # Schreibe Log sofort
          File.write('BITMAP_LOAD_LOG.txt', @@load_log.join("\n"))
        end
        
        # Versuche aus GameData.pack zu laden
        data = GameLoader.get_file(path)
        
        if @@temp_counter <= 20
          @@load_log << "   → get_file returned: #{data ? data.bytesize : 'NIL'} bytes"
          File.write('BITMAP_LOAD_LOG.txt', @@load_log.join("\n"))
        end
        
        # Falls nicht gefunden, versuche mit .png Endung
        if !data && !path.end_with?('.png', '.PNG')
          data = GameLoader.get_file(path + '.png')
          if @@temp_counter <= 20
            @@load_log << "   → with .png: #{data ? data.bytesize : 'NIL'} bytes"
            File.write('BITMAP_LOAD_LOG.txt', @@load_log.join("\n"))
          end
        end
        
        if data
          begin
            # TEMP: Schreibe in C:\Temp (Windows Temp Directory)
            temp_dir = "C:/Temp"
            Dir.mkdir(temp_dir) unless Dir.exist?(temp_dir)
            temp_file = File.join(temp_dir, "pokegame_bmp_#{@@temp_counter}.png")
            
            if @@temp_counter <= 20
              @@load_log << "   → Writing temp file: #{temp_file}"
              File.write('BITMAP_LOAD_LOG.txt', @@load_log.join("\n"))
            end
            
            # Schreibe PNG temporär (NUR für Bitmap.new Dekodierung)
            File.open(temp_file, 'wb') { |f| f.write(data) }
            
            if @@temp_counter <= 20
              @@load_log << "   → File written, size: #{File.size(temp_file)} bytes"
              @@load_log << "   → File exists?: #{File.exist?(temp_file)}"
              File.write('BITMAP_LOAD_LOG.txt', @@load_log.join("\n"))
            end
            
            if @@temp_counter <= 20
              @@load_log << "   → Loading bitmap from temp..."
              File.write('BITMAP_LOAD_LOG.txt', @@load_log.join("\n"))
            end
            
            # Lade Bitmap aus temp Datei
            # Rufe die ECHTE Bitmap.new auf (über super chain)
            super(temp_file)
            
            # NICHT löschen für Debug!
            # if @@temp_counter <= 20
            #   @@load_log << "   → Deleting temp file..."
            #   File.write('BITMAP_LOAD_LOG.txt', @@load_log.join("\n"))
            # end
            
            # # LÖSCHE temp Datei SOFORT nach dem Laden
            # File.delete(temp_file) if File.exist?(temp_file)
            
            # Track success
            @@loaded_from_pack += 1
            if @@temp_counter <= 20
              @@load_log << "   ✓ SUCCESS from pack!"
              File.write('BITMAP_LOAD_LOG.txt', @@load_log.join("\n"))
            end
            
            # Initialisiere BitmapWrapper-Attribute
            @refcount = 1
            @never_dispose = false
            return
          rescue => e
            if @@temp_counter <= 20
              @@load_log << "   ✗ ERROR: #{e.class} - #{e.message}"
              @@load_log << "   Backtrace: #{e.backtrace.first(3).join(' | ')}"
              File.write('BITMAP_LOAD_LOG.txt', @@load_log.join("\n"))
            end
            # Fall through to filesystem fallback
          end
        elsif @@temp_counter <= 20
          @@load_log << "   ✗ NOT FOUND in pack (will try filesystem)"
          File.write('BITMAP_LOAD_LOG.txt', @@load_log.join("\n"))
        end
      end
      
      # Fallback: Normale Initialisierung (für Bitmaps die nicht im Pack sind)
      bitmap_initialize_original(*args)
      @refcount = 1 if args.length >= 1 && args[0].is_a?(String)
    end
  end
  
  # Cleanup: Lösche temp Ordner beim Spielende
  at_exit do
    temp_dir = GameLoader::TEMP_BITMAP_DIR
    if Dir.exist?(temp_dir)
      Dir.foreach(temp_dir) do |file|
        next if file == "." || file == ".."
        File.delete(File.join(temp_dir, file)) rescue nil
      end
      Dir.rmdir(temp_dir) rescue nil
    end
  end
  
  puts "✓ BitmapLoader activated - Graphics werden aus verschlüsseltem Pack geladen"
  puts "  (Temp files werden sofort nach dem Laden gelöscht)"
else
  puts "⚠ BitmapLoader NICHT aktiviert (GameLoader oder BitmapWrapper fehlt)"
end

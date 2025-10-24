#===============================================================================
# FPK Builder - Build Tool for Creating FPK Packages
# Run this from the Debug menu to create encrypted packages
#===============================================================================

module FPKBuilder
  #-----------------------------------------------------------------------------
  # Build configuration
  #-----------------------------------------------------------------------------
  RELEASE_DIR = "Release_Build"
  
  PACKAGES = {
    "Graphics/Assets_0-.fpk" => {
      :source => "Graphics",
      :extensions => [".png", ".gif", ".jpg", ".jpeg", ".bmp"],
      :exclude => ["Assets_0-.fpk"]
    },
    "Data/Data_0-.fpk" => {
      :source => "Data",
      :extensions => [".rxdata", ".rvdata", ".rvdata2"],  # Removed .dat - will be copied instead
      :exclude => [
        "Data_0-.fpk", 
        "Scripts.rxdata",
        "PluginScripts.rxdata",
        # RPG Maker system files (needed at startup)
        "Actors.rxdata",
        "Animations.rxdata", 
        "Armors.rxdata",
        "Classes.rxdata",
        "CommonEvents.rxdata",
        "Enemies.rxdata",
        "Items.rxdata",
        "MapInfos.rxdata",
        "PkmnAnimations.rxdata",
        "Skills.rxdata",
        "States.rxdata",
        "System.rxdata",
        "Tilesets.rxdata",
        "Troops.rxdata",
        "Weapons.rxdata",
        # Starting map (loaded before FPK system is ready)
        "Map001.rxdata"
      ]
    },
    "Audio/Audio_0-.fpk" => {
      :source => "Audio",
      :extensions => [".ogg", ".mp3", ".wav", ".mid", ".midi"],
      :exclude => ["Audio_0-.fpk"]
    }
  }
  
  # Files/folders to copy to release build
  COPY_TO_RELEASE = [
    # Scripts (essential for game startup)
    "Data/Scripts",
    "Data/Scripts.rxdata",
    "Data/PluginScripts.rxdata",
    # RPG Maker system files (needed at startup)
    "Data/Actors.rxdata",
    "Data/Animations.rxdata",
    "Data/Armors.rxdata", 
    "Data/Classes.rxdata",
    "Data/CommonEvents.rxdata",
    "Data/Enemies.rxdata",
    "Data/Items.rxdata",
    "Data/MapInfos.rxdata",
    "Data/PkmnAnimations.rxdata",
    "Data/Skills.rxdata",
    "Data/States.rxdata",
    "Data/System.rxdata",
    "Data/Tilesets.rxdata",
    "Data/Troops.rxdata",
    "Data/Weapons.rxdata",
    # Starting map (loaded before FPK system is ready)
    "Data/Map001.rxdata",
    # PBS compiled data files (needed at startup)
    "Data/abilities.dat",
    "Data/adventure_maps.dat",
    "Data/berry_plants.dat",
    "Data/dungeon_parameters.dat",
    "Data/dungeon_tilesets.dat",
    "Data/encounters.dat",
    "Data/items.dat",
    "Data/map_connections.dat",
    "Data/map_metadata.dat",
    "Data/messages_core.dat",
    "Data/messages_game.dat",
    "Data/metadata.dat",
    "Data/move2anim.dat",
    "Data/moves.dat",
    "Data/phone.dat",
    "Data/player_metadata.dat",
    "Data/regional_dexes.dat",
    "Data/ribbons.dat",
    "Data/species.dat",
    "Data/species_metrics.dat",
    "Data/town_map.dat",
    "Data/trainers.dat",
    "Data/trainer_lists.dat",
    "Data/trainer_types.dat",
    "Data/types.dat",
    # Configuration files
    "Game.ini",
    "Game.rxproj",
    "mkxp.json",
    "soundfont.sf2",
    # PBS folder and Plugins folder
    "PBS",
    "Plugins"
  ]
  
  #-----------------------------------------------------------------------------
  # Helper: Copy directory recursively
  #-----------------------------------------------------------------------------
  def self.copy_directory(src, dest)
    Dir.mkdir(dest) if !FileTest.directory?(dest)
    
    Dir.foreach(src) do |item|
      next if item == '.' || item == '..'
      
      src_path = File.join(src, item)
      dest_path = File.join(dest, item)
      
      if FileTest.directory?(src_path)
        copy_directory(src_path, dest_path)
      else
        File.open(src_path, "rb") do |s|
          File.open(dest_path, "wb") do |d|
            d.write(s.read)
          end
        end
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Build all packages and create release folder
  #-----------------------------------------------------------------------------
  def self.build_all
    Console.echo_h1("FPK Package Builder - Release Build")
    Console.echo_li("Creating release build folder...")
    
    # Create release directory
    Dir.mkdir(RELEASE_DIR) if !FileTest.directory?(RELEASE_DIR)
    
    # Create subdirectories
    ["Graphics", "Data", "Audio"].each do |dir|
      full_path = File.join(RELEASE_DIR, dir)
      Dir.mkdir(full_path) if !FileTest.directory?(full_path)
    end
    
    total_files = 0
    total_original_size = 0
    total_compressed_size = 0
    
    # Build packages into release folder
    PACKAGES.each do |package_path, config|
      release_package_path = File.join(RELEASE_DIR, package_path)
      result = self.build_package(release_package_path, config)
      if result
        total_files += result[:file_count]
        total_original_size += result[:original_size]
        total_compressed_size += result[:compressed_size]
      end
    end
    
    # Copy essential files
    Console.echo_li("Copying essential files to release...")
    COPY_TO_RELEASE.each do |path|
      if FileTest.directory?(path)
        # Copy directory recursively
        dest = File.join(RELEASE_DIR, path)
        if !FileTest.directory?(dest)
          copy_directory(path, dest)
        end
      elsif FileTest.exist?(path)
        # Copy file - preserve directory structure
        dest = File.join(RELEASE_DIR, path)
        # Create directory if needed
        dest_dir = File.dirname(dest)
        Dir.mkdir(dest_dir) if !FileTest.directory?(dest_dir)
        # Copy file
        File.open(path, "rb") do |src|
          File.open(dest, "wb") do |dst|
            dst.write(src.read)
          end
        end
      end
    end
    
    Console.echo_done(true)
    Console.echo_li("Total files packaged: #{total_files}")
    Console.echo_li("Original size: #{format_size(total_original_size)}")
    Console.echo_li("Compressed size: #{format_size(total_compressed_size)}")
    ratio = ((total_compressed_size.to_f / total_original_size.to_f) * 100).round(2)
    Console.echo_li("Compression ratio: #{ratio}%%")
    Console.echo_li("Release build created in: #{RELEASE_DIR}/")
    
    pbMessage("Release build complete!\n\n" +
              "Files: #{total_files}\n" +
              "Original: #{format_size(total_original_size)}\n" +
              "Compressed: #{format_size(total_compressed_size)}\n" +
              "Ratio: #{ratio}%%\n\n" +
              "Location: #{RELEASE_DIR}/")
  end
  
  #-----------------------------------------------------------------------------
  # Build a single package
  #-----------------------------------------------------------------------------
  def self.build_package(package_path, config)
    Console.echo_h2("Building #{package_path}")
    
    # Get all files
    files = collect_files(config[:source], config[:extensions], config[:exclude])
    
    if files.empty?
      Console.echo_warn("No files found in #{config[:source]}")
      return nil
    end
    
    Console.echo_li("Found #{files.length} files")
    
    # Create index
    index = {}
    data_stream = ""
    current_offset = 0
    
    original_size = 0
    compressed_size = 0
    
    files.each_with_index do |file_path, i|
      echo "." if i % 100 == 0
      Graphics.update if i % 500 == 0
      
      # Read file
      file_data = nil
      File.open(file_path, "rb") { |f| file_data = f.read }
      original_size += file_data.bytesize
      
      # Compress
      compressed = Zlib::Deflate.deflate(file_data, Zlib::BEST_COMPRESSION)
      
      # Encrypt
      encrypted = FPK.encrypt(compressed)
      
      # Add to index
      relative_path = file_path.gsub("\\", "/")
      index[relative_path] = {
        "offset" => current_offset,
        "size" => encrypted.bytesize,
        "original_size" => file_data.bytesize
      }
      
      # Add to data stream
      data_stream << encrypted
      current_offset += encrypted.bytesize
      compressed_size += encrypted.bytesize
    end
    
    Console.echo_li("Writing package...")
    
    # Convert index to JSON
    index_json = JSON.encode(index)
    
    # Encrypt index
    encrypted_index = FPK.encrypt(index_json)
    
    # Write package with anti-analysis measures
    File.open(package_path, "wb") do |f|
      # Magic header (custom, not ZIP/RAR)
      f.write(FPK::MAGIC)
      
      # Random padding to confuse hex editors (4-16 bytes)
      padding_size = 4 + rand(13)
      f.write([padding_size].pack("C"))  # Write padding size first!
      f.write(Random.new.bytes(padding_size))
      
      # Index size (encrypted location marker)
      f.write([encrypted_index.bytesize].pack("L"))
      
      # More random padding
      f.write(Random.new.bytes(8))
      
      # Encrypted index
      f.write(encrypted_index)
      
      # Random padding between index and data
      f.write(Random.new.bytes(16))
      
      # File data (already encrypted)
      f.write(data_stream)
      
      # Random padding at end to hide file size patterns
      f.write(Random.new.bytes(32 + rand(64)))
    end
    
    Console.echo_done(true)
    Console.echo_li("Package created: #{format_size(File.size(package_path))}")
    
    return {
      :file_count => files.length,
      :original_size => original_size,
      :compressed_size => compressed_size
    }
  end
  
  #-----------------------------------------------------------------------------
  # Collect files from directory
  #-----------------------------------------------------------------------------
  def self.collect_files(source_dir, extensions, exclude = [])
    files = []
    
    return files if !FileTest.directory?(source_dir)
    
    # Get all files recursively
    Dir.glob("#{source_dir}/**/*").each do |path|
      next if FileTest.directory?(path)
      
      # Check extension
      ext = File.extname(path).downcase
      next if !extensions.include?(ext)
      
      # Check exclude
      filename = File.basename(path)
      next if exclude.include?(filename)
      
      files.push(path)
    end
    
    return files
  end
  
  #-----------------------------------------------------------------------------
  # Format byte size
  #-----------------------------------------------------------------------------
  def self.format_size(bytes)
    if bytes < 1024
      return "#{bytes} B"
    elsif bytes < 1024 * 1024
      return "#{(bytes / 1024.0).round(2)} KB"
    else
      return "#{(bytes / (1024.0 * 1024.0)).round(2)} MB"
    end
  end
  
  #-----------------------------------------------------------------------------
  # Clean up - remove original files (USE WITH CAUTION!)
  #-----------------------------------------------------------------------------
  def self.clean_source_files
    if pbConfirmMessage("This will DELETE all source files that were packaged.\n" +
                        "Only use this for final release builds!\n\n" +
                        "Are you ABSOLUTELY sure?")
      if pbConfirmMessage("Really? This cannot be undone!")
        Console.echo_warn("Cleaning source files...")
        
        PACKAGES.each do |package_path, config|
          files = collect_files(config[:source], config[:extensions], config[:exclude])
          files.each do |file_path|
            File.delete(file_path) if FileTest.exist?(file_path)
          end
          
          # Remove empty directories
          Dir.glob("#{config[:source]}/**/").reverse_each do |dir|
            Dir.rmdir(dir) if Dir.empty?(dir) rescue nil
          end
        end
        
        Console.echo_done
        pbMessage("Source files cleaned!")
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Extract package (for debugging)
  #-----------------------------------------------------------------------------
  def self.extract_package(package_path, output_dir)
    Console.echo_h2("Extracting #{package_path}")
    
    package = FPK.load_package(package_path)
    if !package
      Console.echo_error("Failed to load package")
      return
    end
    
    Dir.mkdir(output_dir) if !FileTest.directory?(output_dir)
    
    package[:index].each_with_index do |(file_path, file_info), i|
      Console.echo_dot if i % 100 == 0
      
      # Get file data
      data = FPK.get_file(package_path, file_path)
      
      # Create directories
      full_path = File.join(output_dir, file_path)
      dir = File.dirname(full_path)
      FileUtils.mkdir_p(dir) if !FileTest.directory?(dir)
      
      # Write file
      File.open(full_path, "wb") { |f| f.write(data) }
    end
    
    Console.echo_done
    Console.echo_li("Extracted #{package[:index].length} files to #{output_dir}")
  end
end

#===============================================================================
# Debug menu integration
#===============================================================================

# Add separator for FPK section
MenuHandlers.add(:debug_menu, :delim_fpk_encryption, {
  "parent" => :pbs_editors_menu
})

MenuHandlers.add(:debug_menu, :build_fpk_packages, {
  "name"        => _INTL("Build FPK Packages"),
  "parent"      => :pbs_editors_menu,
  "description" => _INTL("Create encrypted asset packages for release"),
  "effect"      => proc {
    FPKBuilder.build_all
  }
})

MenuHandlers.add(:debug_menu, :extract_fpk_package, {
  "name"        => _INTL("Extract FPK Package"),
  "parent"      => :pbs_editors_menu,
  "description" => _INTL("Extract a package for debugging"),
  "effect"      => proc {
    packages = ["Graphics/Assets_0-.fpk", "Data/Data_0-.fpk", "Audio/Audio_0-.fpk"]
    existing = packages.select { |p| FileTest.exist?(p) }
    if existing.empty?
      pbMessage(_INTL("No FPK packages found!"))
      next
    end
    
    cmd = 0
    loop do
      cmds = existing.map { |p| File.basename(p) }
      cmds.push(_INTL("Cancel"))
      cmd = pbShowCommands(nil, cmds, -1, cmd)
      break if cmd < 0 || cmd >= existing.length
      
      package = existing[cmd]
      output = "FPK_Extracted/#{File.basename(package, '.fpk')}"
      FPKBuilder.extract_package(package, output)
      pbMessage(_INTL("Package extracted to {1}/", output))
      break
    end
  }
})

MenuHandlers.add(:debug_menu, :clean_fpk_source_files, {
  "name"        => _INTL("Clean FPK Source Files"),
  "parent"      => :pbs_editors_menu,
  "description" => _INTL("Delete source files after packaging (CAUTION!)"),
  "effect"      => proc {
    FPKBuilder.clean_source_files
  }
})

MenuHandlers.add(:debug_menu, :toggle_fpk_dev_mode, {
  "name"        => _INTL("Toggle FPK Mode"),
  "parent"      => :pbs_editors_menu,
  "description" => _INTL("Switch between dev and release mode"),
  "effect"      => proc {
    FPK.dev_mode = !FPK.dev_mode
    mode_text = FPK.dev_mode ? _INTL("Development") : _INTL("Release")
    pbMessage(_INTL("FPK Mode: {1}", mode_text))
  }
})

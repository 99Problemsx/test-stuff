#===============================================================================
# FPK (File Package) System - Core
# Version 1.0
#-------------------------------------------------------------------------------
# File Package System for encrypting and compressing game assets
# Similar to Pokémon Flux's asset management system
#
# Features:
# - Compress multiple files into single .fpk archives
# - Encrypt file data for protection
# - Transparent loading (automatically switches between dev/release mode)
# - Index-based fast file lookup
#===============================================================================

module FPK
  # Encryption key - CHANGE THIS FOR YOUR GAME!
  # Use a long, random key for maximum security
  ENCRYPTION_KEY = "ZoruaTheDivineDeception2025_SecretKey_DoNotShare_v1.0"
  
  # Magic header to identify FPK files (encrypted)
  # This is NOT the same as ZIP/RAR headers
  MAGIC = "ZRUA"
  
  # Development mode - loads from normal files
  # Release mode - loads from .fpk packages
  @@dev_mode = true
  
  # Cache for loaded packages
  @@packages = {}
  
  # Cache for extracted files
  @@file_cache = {}
  
  #-----------------------------------------------------------------------------
  # Set development mode
  #-----------------------------------------------------------------------------
  def self.dev_mode=(value)
    @@dev_mode = value
  end
  
  def self.dev_mode
    return @@dev_mode
  end
  
  #-----------------------------------------------------------------------------
  # Initialize - Auto-detect mode based on file existence
  #-----------------------------------------------------------------------------
  def self.initialize
    # If FPK files exist, we're in release mode
    if FileTest.exist?("Graphics/Assets_0-.fpk") || FileTest.exist?("Data/Data_0-.fpk")
      @@dev_mode = false
      Console.echo_li("FPK System: Release mode activated")
    else
      @@dev_mode = true
      Console.echo_li("FPK System: Development mode activated")
    end
  end
  
  #-----------------------------------------------------------------------------
  # Determine which package contains a file
  #-----------------------------------------------------------------------------
  def self.get_package_for_path(path)
    # Normalize path
    path = path.gsub("\\", "/")
    
    # Check Graphics package
    if path.start_with?("Graphics/")
      return "Graphics/Assets_0-.fpk"
    # Check Data package
    elsif path.start_with?("Data/")
      return "Data/Data_0-.fpk"
    # Check Audio package
    elsif path.start_with?("Audio/")
      return "Audio/Audio_0-.fpk"
    end
    
    return nil
  end
  
  #-----------------------------------------------------------------------------
  # Load a package file
  #-----------------------------------------------------------------------------
  def self.load_package(package_path)
    return nil if !FileTest.exist?(package_path)
    return @@packages[package_path] if @@packages[package_path]
    
    package_data = nil
    File.open(package_path, "rb") do |f|
      # Read and verify magic header
      magic = f.read(4)
      if magic != MAGIC
        raise "Invalid FPK file: #{package_path}"
      end
      
      # Read padding size, then skip padding
      padding_size = f.read(1).unpack("C")[0]
      f.seek(f.pos + padding_size)
      
      # Read index size
      index_size = f.read(4).unpack("L")[0]
      
      # Skip more padding (8 bytes)
      f.seek(f.pos + 8)
      
      # Read and decrypt index
      encrypted_index = f.read(index_size)
      index_json = self.decrypt(encrypted_index)
      index = JSON.decode(index_json)
      
      # Skip padding between index and data (16 bytes)
      f.seek(f.pos + 16)
      
      # Store package data with correct offset
      data_start = f.pos
      package_data = {
        :file => package_path,
        :index => index,
        :data_offset => data_start
      }
    end
    
    @@packages[package_path] = package_data
    return package_data
  end
  
  #-----------------------------------------------------------------------------
  # Get file from package
  #-----------------------------------------------------------------------------
  def self.get_file(package_path, file_path)
    # Check cache first
    cache_key = "#{package_path}:#{file_path}"
    return @@file_cache[cache_key] if @@file_cache[cache_key]
    
    # Load package if not loaded
    package = self.load_package(package_path)
    return nil if !package
    
    # Find file in index
    file_info = package[:index][file_path]
    return nil if !file_info
    
    # Read file data
    data = nil
    File.open(package[:file], "rb") do |f|
      f.seek(package[:data_offset] + file_info["offset"])
      compressed_data = f.read(file_info["size"])
      
      # Decrypt
      decrypted_data = self.decrypt(compressed_data)
      
      # Decompress
      data = Zlib::Inflate.inflate(decrypted_data)
    end
    
    # Cache the data
    @@file_cache[cache_key] = data
    
    return data
  end
  
  #-----------------------------------------------------------------------------
  # Multi-layer XOR encryption with byte rotation
  # This prevents simple RAR/ZIP detection and extraction
  #-----------------------------------------------------------------------------
  def self.encrypt(data)
    # Convert to binary string
    result = data.dup.force_encoding('ASCII-8BIT')
    key_bytes = ENCRYPTION_KEY.bytes
    key_length = key_bytes.length
    
    # Layer 1: XOR encryption with key
    result.bytes.each_with_index do |byte, i|
      result.setbyte(i, byte ^ key_bytes[i % key_length])
    end
    
    # Layer 2: Byte rotation based on position and key
    rotated = ""
    result.bytes.each_with_index do |byte, i|
      rotation = (key_bytes[i % key_length] + i) % 256
      rotated << ((byte + rotation) % 256).chr
    end
    
    # Layer 3: Reverse XOR with shifted key
    final = ""
    rotated.bytes.each_with_index do |byte, i|
      key_shift = (i + key_length) % key_length
      final << (byte ^ key_bytes[key_shift]).chr
    end
    
    return final.force_encoding('ASCII-8BIT')
  end
  
  def self.decrypt(data)
    # Reverse of encryption layers
    result = data.dup.force_encoding('ASCII-8BIT')
    key_bytes = ENCRYPTION_KEY.bytes
    key_length = key_bytes.length
    
    # Reverse Layer 3: XOR with shifted key
    step1 = ""
    result.bytes.each_with_index do |byte, i|
      key_shift = (i + key_length) % key_length
      step1 << (byte ^ key_bytes[key_shift]).chr
    end
    
    # Reverse Layer 2: Byte rotation
    step2 = ""
    step1.bytes.each_with_index do |byte, i|
      rotation = (key_bytes[i % key_length] + i) % 256
      step2 << ((byte - rotation) % 256).chr
    end
    
    # Reverse Layer 1: XOR encryption
    final = ""
    step2.bytes.each_with_index do |byte, i|
      final << (byte ^ key_bytes[i % key_length]).chr
    end
    
    return final.force_encoding('ASCII-8BIT')
  end
  
  #-----------------------------------------------------------------------------
  # Clear cache
  #-----------------------------------------------------------------------------
  def self.clear_cache
    @@file_cache.clear
    GC.start
  end
  
  #-----------------------------------------------------------------------------
  # Get package path for a file type
  #-----------------------------------------------------------------------------
  def self.get_package_for_path(path)
    if path.start_with?("Graphics/")
      return "Graphics/Assets_0-.fpk"
    elsif path.start_with?("Data/")
      return "Data/Data_0-.fpk"
    elsif path.start_with?("Audio/")
      return "Audio/Audio_0-.fpk"
    end
    return nil
  end
  
end

# Initialize on load
FPK.initialize

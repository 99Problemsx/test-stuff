#===============================================================================
# FPK System - File Loader Override
# Overrides standard file loading to use FPK packages when available
#===============================================================================

module FPK
  #-----------------------------------------------------------------------------
  # Load bitmap with FPK support
  #-----------------------------------------------------------------------------
  def self.load_bitmap(path)
    # Dev mode - use normal loading
    if @@dev_mode
      return Bitmap.new(path)
    end
    
    # Normalize path
    path = path.gsub("\\", "/")
    
    # Release mode - try FPK first
    package_path = FPK.get_package_for_path(path)
    if package_path && FileTest.exist?(package_path)
      # Try to find file with or without extension
      actual_path = path
      package = FPK.load_package(package_path)
      
      if package
        # Try exact match first
        if !package[:index].has_key?(actual_path) && !path.include?(".")
          # Try with common extensions
          [".png", ".gif", ".jpg", ".jpeg"].each do |ext|
            test_path = path + ext
            if package[:index].has_key?(test_path)
              actual_path = test_path
              break
            end
          end
        end
        
        # Debug output
        Console.echo_warn("Loading bitmap: #{path} -> #{actual_path}") if actual_path != path
        
        data = FPK.get_file(package_path, actual_path)
        if data
          # Create bitmap from data using unique temp file
          temp_file = "temp_bitmap_#{Time.now.to_i}_#{rand(10000)}.png"
          begin
            File.open(temp_file, "wb") { |f| f.write(data) }
            bitmap = Bitmap.new(temp_file)
            File.delete(temp_file) if FileTest.exist?(temp_file)
            return bitmap
          rescue => e
            File.delete(temp_file) if FileTest.exist?(temp_file)
            Console.echo_error("Failed to load bitmap from FPK: #{actual_path}")
            Console.echo_error("Error: #{e.message}")
            raise e
          end
        else
          Console.echo_warn("File not found in package: #{actual_path}")
        end
      end
    end
    
    # Fallback to normal loading only if file actually exists
    if FileTest.exist?(path)
      return Bitmap.new(path)
    end
    
    # File not found anywhere
    raise "File not found: #{path} (not in FPK and not on disk)"
  end
  
  #-----------------------------------------------------------------------------
  # Load data with FPK support
  #-----------------------------------------------------------------------------
  def self.load_data(path)
    # Dev mode - use normal loading
    if @@dev_mode
      return load_data_original(path)
    end
    
    # Release mode - try FPK first
    package_path = self.get_package_for_path(path)
    if package_path
      data = self.get_file(package_path, path)
      if data
        return Marshal.load(data)
      end
    end
    
    # Fallback to normal loading
    return load_data_original(path)
  end
  
  #-----------------------------------------------------------------------------
  # Read file with FPK support
  #-----------------------------------------------------------------------------
  def self.read_file(path)
    # Dev mode - use normal loading
    if @@dev_mode
      return File.read(path)
    end
    
    # Release mode - try FPK first
    package_path = self.get_package_for_path(path)
    if package_path
      data = self.get_file(package_path, path)
      return data if data
    end
    
    # Fallback to normal loading
    return File.read(path)
  end
  
  #-----------------------------------------------------------------------------
  # Check if file exists (including in packages)
  #-----------------------------------------------------------------------------
  def self.file_exists?(path)
    # Dev mode - normal check
    if @@dev_mode
      return FileTest.exist?(path)
    end
    
    # Normalize path
    path = path.gsub("\\", "/")
    
    # Release mode - check in package
    package_path = FPK.get_package_for_path(path)
    if package_path
      package = FPK.load_package(package_path)
      if package
        # Try exact match first
        return true if package[:index].has_key?(path)
        
        # Try with common extensions if no extension provided
        if !path.include?(".")
          [".png", ".gif", ".jpg", ".jpeg"].each do |ext|
            return true if package[:index].has_key?(path + ext)
          end
        end
      end
    end
    
    # Fallback to normal check
    return FileTest.exist?(path)
  end
end

#===============================================================================
# Override pbResolveBitmap to use FPK system
#===============================================================================
alias fpk_pbResolveBitmap pbResolveBitmap unless defined?(fpk_pbResolveBitmap)

def pbResolveBitmap(file)
  if !FPK.dev_mode
    # In release mode, check if file exists in FPK
    if FPK.file_exists?(file)
      return file
    end
  end
  # Fallback to original method
  return fpk_pbResolveBitmap(file)
end

#===============================================================================
# Override RPG Cache to use FPK system (if needed)
#===============================================================================
module RPG
  module Cache
    class << self
      alias fpk_load_bitmap load_bitmap unless method_defined?(:fpk_load_bitmap)
      
      def load_bitmap(folder_name, filename, hue = 0)
        if !FPK.dev_mode
          path = folder_name + filename
          if FPK.file_exists?(path)
            bitmap = FPK.load_bitmap(path)
            pbSetSystemColor(bitmap, hue) if hue != 0
            return bitmap
          end
        end
        # Fallback to original
        return fpk_load_bitmap(folder_name, filename, hue)
      end
    end
  end
end

Console.echo_li("FPK Loader overrides installed")

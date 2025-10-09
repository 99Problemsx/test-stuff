#===============================================================================
# Enhanced Text System for Plugins
# Adds "Extract plugin text" and "Compile plugin text" to Debug menu
# Compatible with Essentials v21.1
#===============================================================================

module MessageTypes
  PLUGIN_TEXTS = 25 unless const_defined?(:PLUGIN_TEXTS)
end

# Extract all _INTL calls from plugin files
module PluginTextExtractor
  def self.extract_plugin_texts
    texts = {}
    file_count = 0
    
    Console.echo_li("Scanning plugin files...")
    Dir.glob("Plugins/**/*.rb").each do |file|
      next if file.include?("Enhanced Text System")
      
      file_count += 1
      content = File.read(file, encoding: 'UTF-8')
      
      # Find all _INTL calls
      content.scan(/_INTL\s*\(\s*["']([^"']+)["']/).each do |match|
        text = match[0]
        
        # Skip texts that are just Ruby interpolations or variables
        next if text.strip.start_with?('#')  # Skip #{...} interpolations
        next if text.strip.empty?            # Skip empty texts
        next if text =~ /^[\s\#\{\}\[\]\(\)]+$/ # Skip texts with only special chars
        
        texts[text] = text unless texts.key?(text)
      end
    end
    
    Console.echo_li("Scanned #{file_count} plugin files")
    Console.echo_li("Found #{texts.size} unique plugin texts")
    return texts
  end
  
  def self.write_plugin_texts(language_name, texts)
    dir_name = (language_name == "default") ? "" : language_name + "_"
    dir_name = sprintf("Text_%score", dir_name)
    Dir.mkdir(dir_name) if !File.directory?(dir_name)
    
    filename = File.join(dir_name, "PLUGIN_TEXTS.txt")
    File.open(filename, "wb") { |f|
      f.write("\xEF\xBB\xBF") # UTF-8 BOM
      
      # Single section header like other text files
      f.write("[PLUGIN_TEXTS]\r\n")
      
      # Write texts in pairs: original, translation (duplicate for now)
      texts.sort.each do |key, text|
        f.write(text + "\r\n")
        f.write(text + "\r\n") # Duplicate for translation
      end
    }
    
    Console.echo_li("Plugin texts written to #{filename}")
    return filename
  end
end

# Add separator
MenuHandlers.add(:debug_menu, :delim_extract_plugin, {
  "parent"      => :delim_extract
})

# Add "Extract plugin text" to Debug menu
MenuHandlers.add(:debug_menu, :extract_plugin_text, {
  "name"        => _INTL("Extract plugin text"),
  "parent"      => :delim_extract,
  "description" => _INTL("Extract all text from plugins for translation."),
  "always_show" => false,
  "effect"      => proc {
    if !Settings::LANGUAGES || Settings::LANGUAGES.empty?
      pbMessage(_INTL("No languages are defined in the LANGUAGES array in Settings."))
      next
    end
    
    # Choose language
    lang_commands = []
    Settings::LANGUAGES.each { |lang| lang_commands.push(lang[0]) }
    lang_commands.push(_INTL("Cancel"))
    lang = pbShowCommands(nil, lang_commands, -1)
    next if lang < 0 || lang >= Settings::LANGUAGES.length
    
    language_name = Settings::LANGUAGES[lang][1]
    
    # Extract plugin texts
    Console.echo_h1(_INTL("Extracting plugin text to files"))
    texts = PluginTextExtractor.extract_plugin_texts
    
    if texts.empty?
      pbMessage(_INTL("No plugin texts found."))
    else
      filename = PluginTextExtractor.write_plugin_texts(language_name, texts)
      pbMessage(_INTL("Plugin text was extracted to files in the folder \"{1}\".", File.dirname(filename)))
    end
  }
})

# Add "Compile plugin text" to Debug menu
MenuHandlers.add(:debug_menu, :compile_plugin_text, {
  "name"        => _INTL("Compile plugin text"),
  "parent"      => :delim_extract,
  "description" => _INTL("Compile translated plugin text."),
  "always_show" => false,
  "effect"      => proc {
    if !Settings::LANGUAGES || Settings::LANGUAGES.empty?
      pbMessage(_INTL("No languages are defined in the LANGUAGES array in Settings."))
      next
    end
    
    # Choose language
    lang_commands = []
    Settings::LANGUAGES.each { |lang| lang_commands.push(lang[0]) }
    lang_commands.push(_INTL("Cancel"))
    lang = pbShowCommands(nil, lang_commands, -1)
    next if lang < 0 || lang >= Settings::LANGUAGES.length
    
    language_name = Settings::LANGUAGES[lang][1]
    
    # Compile plugin texts
    Console.echo_h1(_INTL("Compiling plugin text"))
    MessageTypes.compile_text(language_name, true)
    pbMessage(_INTL("Plugin text was compiled."))
  }
})

Console.echo_li("Enhanced Text System: Plugin text extraction added to Debug menu")

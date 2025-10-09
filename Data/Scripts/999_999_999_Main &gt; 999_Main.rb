class Scene_DebugIntro
  def main
    Graphics.transition(0)
    sscene = PokemonLoad_Scene.new
    sscreen = PokemonLoadScreen.new(sscene)
    sscreen.pbStartLoadScreen
    Graphics.freeze
  end
end

def pbCallTitle
  return Scene_DebugIntro.new if $DEBUG
  return Scene_Intro.new
end

####Custom Edit: 08.09.25 https://eeveeexpo.com/resources/1242/####
def mainFunction
#if $DEBUG
pbCriticalCode { mainFunctionDebug }
# else
# mainFunctionDebug
# end
return 1
end

def mainFunctionDebug
  begin
    MessageTypes.load_default_messages if FileTest.exist?("Data/messages_core.dat")
    PluginManager.runPlugins
    Compiler.main
    Game.initialize
    Game.set_up_system
    Graphics.update
    Graphics.freeze
    $scene = pbCallTitle
    $scene.main until $scene.nil?
    Graphics.transition
  rescue Hangup
    pbPrintException($!) if !$DEBUG
    pbEmergencySave
    raise
  end
end

loop do
  retval = mainFunction
  case retval
  when 0   # failed
    loop do
      Graphics.update
    end
  when 1   # ended successfully
    # CLEANUP: Lösche extrahierte Graphics vor Beenden
    if defined?(GameLoader)
      begin
        graphics_dir = "Graphics"
        if Dir.exist?(graphics_dir)
          Dir.glob(File.join(graphics_dir, "**", "*")).reverse.each do |file|
            File.delete(file) if File.file?(file)
            Dir.rmdir(file) if File.directory?(file) && Dir.empty?(file)
          end
          Dir.rmdir(graphics_dir) if Dir.exist?(graphics_dir) && Dir.empty?(graphics_dir)
          File.write('CLEANUP_LOG.txt', "✓ Graphics cleaned up\n")
        end
      rescue => e
        File.write('CLEANUP_LOG.txt', "ERROR: #{e.message}\n")
      end
    end
    break
  end
end

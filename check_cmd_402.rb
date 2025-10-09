require 'zlib'

def load_data(filename)
  File.open(filename, 'rb') do |file|
    Marshal.load(file)
  end
end

# Load Map 1 which has working choice commands
map = load_data('Data/Map001.rxdata')

puts "=== Checking Command 402 structure in Map 1 ==="
map.events.each do |event_id, event|
  event.pages.each_with_index do |page, page_idx|
    page.list.each_with_index do |cmd, cmd_idx|
      if cmd.code == 402
        puts "\nEvent: #{event.name}"
        puts "Page: #{page_idx + 1}"
        puts "Command index: #{cmd_idx}"
        puts "Code: #{cmd.code}"
        puts "Indent: #{cmd.indent}"
        puts "Parameters: #{cmd.parameters.inspect}"
        puts "Parameters class: #{cmd.parameters.class}"
        puts "Parameters[0]: #{cmd.parameters[0].inspect} (#{cmd.parameters[0].class})" if cmd.parameters.length > 0
      end
    end
  end
end

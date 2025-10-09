require 'zlib'

# Load RMXP data
def load_data(filename)
  File.open(filename, 'rb') do |f|
    Marshal.load(f)
  end
end

# Load the map with Quest NPC
data = load_data('Data/Map007.rxdata')
event = data.events[40]

puts "Quest NPC Event - Page 0:"
puts "=" * 80
event.pages[0].list.each_with_index do |cmd, i|
  puts format('%3d: Code=%3d Indent=%d Params=%s', i, cmd.code, cmd.indent, cmd.parameters.inspect)
end

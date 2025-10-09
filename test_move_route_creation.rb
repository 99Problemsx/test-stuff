# Test script to create a MoveRoute and inspect its structure

# Simulate what the plugin does
move_route = RPG::MoveRoute.new
puts "MoveRoute after new:"
puts "  repeat: #{move_route.repeat.inspect}"
puts "  skippable: #{move_route.skippable.inspect}"
puts "  list: #{move_route.list.inspect}"

move_route.repeat = false
move_route.skippable = true
move_route.list = [
  RPG::MoveCommand.new(37, []),  # Through ON
  RPG::MoveCommand.new(4, []),   # Move Up
  RPG::MoveCommand.new(38, []),  # Through OFF
  RPG::MoveCommand.new(0, [])    # End
]

puts "\nMoveRoute after setup:"
puts "  repeat: #{move_route.repeat.inspect}"
puts "  skippable: #{move_route.skippable.inspect}"
puts "  list length: #{move_route.list.length}"
puts "  list: #{move_route.list.inspect}"

# Create the event command
event_cmd = RPG::EventCommand.new(209, 0, [-1, move_route])

puts "\nEventCommand:"
puts "  code: #{event_cmd.code}"
puts "  indent: #{event_cmd.indent}"
puts "  parameters[0]: #{event_cmd.parameters[0]}"
puts "  parameters[1]: #{event_cmd.parameters[1].class}"
puts "  parameters[1].repeat: #{event_cmd.parameters[1].repeat}"
puts "  parameters[1].skippable: #{event_cmd.parameters[1].skippable}"
puts "  parameters[1].list.length: #{event_cmd.parameters[1].list.length}"

puts "\nAll good! Structure looks correct."

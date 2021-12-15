lines = File.read_lines("input.txt")

distance = 0
depth = 0

lines
  .reject(&.blank?)
  .map(&.split(' '))
  .each do |(direction, magnitude)|
    magnitude = magnitude.to_i
    case direction
    when "down"
      depth += magnitude
    when "up"
      depth -= magnitude
    when "forward"
      distance += magnitude
    else
      puts "unknown direction: #{direction}"
    end
  end

puts "distance: #{distance}"
puts "depth: #{depth}"

puts "product: #{distance * depth}"
puts "-" * 80

distance = 0
depth = 0
aim = 0

lines
  .reject(&.blank?)
  .map(&.split(' '))
  .each do |(direction, magnitude)|
    magnitude = magnitude.to_i
    case direction
    when "down"
      aim += magnitude
    when "up"
      aim -= magnitude
    when "forward"
      distance += magnitude
      depth += aim * magnitude
    else
      puts "unknown direction: #{direction}"
    end
  end

puts "distance: #{distance}"
puts "depth: #{depth}"

puts "product: #{distance * depth}"

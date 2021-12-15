data = File.read_lines("input.txt").first.split(',').map(&.to_i).sort

min = data.first
max = data.last

puts "min: #{min}"
puts "max: #{max}"
puts "count: #{data.size}"

fuel_summary = Hash(Int32, Int32).new

min.to(max).each do |position|
  fuel_summary[position] = 0
  data.each do |submarine_position|
    fuel_summary[position] += (submarine_position - position).abs
  end
end

minimum = fuel_summary.reduce(0) do |best_position, (position, fuel_cost)|
  if fuel_cost < fuel_summary[best_position]
    position
  else
    best_position
  end
end

puts "Best position: #{minimum}. Total Fuel Cost: #{fuel_summary[minimum]}"
puts "-"*80

fuel_summary.clear

min.to(max).each do |position|
  fuel_summary[position] = 0

  data.each do |submarine_position|
    distance = (submarine_position - position).abs
    cost = distance * (distance + 1) / 2
    fuel_summary[position] += cost.to_i
  end
end

minimum = fuel_summary.reduce(0) do |best_position, (position, fuel_cost)|
  if fuel_cost < fuel_summary[best_position]
    position
  else
    best_position
  end
end

puts "Best position: #{minimum}. Total Fuel Cost: #{fuel_summary[minimum]}"
puts "-"*80


def count_increasing(measurements : Array(Int32)) : Int32
  last = -1
  increasing = 0

  measurements.each do |depth|
    increasing += 1 if depth > last && last > -1
    last = depth
  end

  increasing
end

measurements = File.read_lines("input.txt").map(&.to_i)
count = count_increasing measurements

puts "part 1: increased #{count} times"

aggregated_measurements = [] of Int32

File.read_lines("input.txt")
  .map(&.to_i)
  .each_cons(3) do |set|
    aggregated_measurements << set.sum
  end

count = count_increasing aggregated_measurements

puts "part 2: increased #{count} times"

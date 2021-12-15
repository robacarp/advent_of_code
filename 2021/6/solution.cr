require "big"

class School
  getter fish : Hash(Int32, BigInt)

  def initialize
    @fish = Hash(Int32, BigInt).new { 0.to_big_i }
  end

  def add_fish(age, count = 1)
    @fish[age] += count
  end

  def sunset
    pregnant_fish = @fish[0]
    @fish[0], @fish[1], @fish[2], @fish[3], @fish[4], @fish[5], @fish[6], @fish[7], @fish[8] =
      @fish[1], @fish[2], @fish[3], @fish[4], @fish[5], @fish[6], @fish[7], @fish[8], 0.to_big_i

    @fish[6] += pregnant_fish
    @fish[8] += pregnant_fish
  end

  def size
    @fish.values.sum
  end
end

data = File.read_lines("input.txt").first.split(",").map(&.to_i).sort.group_by(&.itself)

school = School.new
data.each do |age, fish|
  school.add_fish(age, fish.size)
end

puts "#{school.size} fish in school"

80.times do
  school.sunset
  puts "#{school.size} fish in school"
end

176.times do
  school.sunset
  puts "#{school.size} fish in school"
end

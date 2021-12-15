struct Point
  property x : Int32, y : Int32
  def initialize(@x, @y)
  end

  def self.from_s(s)
    x,y = s.split(',').map &.to_i
    new x,y
  end
end

def to_range(a, b)
  if a < b
    (a..b)
  else
    (b..a)
  end
end

vent_lines = File.read_lines("input.txt")
  .map(&.split(" -> "))
  .map do |points|
    points.map {|p| Point.from_s p}
  end

field_size = vent_lines.map {|(start, finish)| [start.x, start.y, finish.x, finish.y].sort.last }.sort.last
field_size += 1
puts "Field size: #{field_size}"

field = Array(Array(Int32)).new(size: field_size) do |r|
  Array(Int32).new(size: field_size) do |c|
    0
  end
end

vent_lines.each do |(start,finish)|
  case
  when (x = start.x) == finish.x # horizontal
    to_range(start.y, finish.y).each do |y|
      field[y][x] += 1
    end

  when (y = start.y) == finish.y # vertical
    to_range(start.x, finish.x).each do |x|
      field[y][x] += 1
    end

  else
    increment_x = start.x > finish.x ? -1 : 1
    increment_y = start.y > finish.y ? -1 : 1

    point_x = start.x
    point_y = start.y

    loop do
      field[point_y][point_x] += 1

      point_x += increment_x
      point_y += increment_y

      break if point_x - increment_x == finish.x
    end
  end
end

count = 0

field.each.with_index do |row, i|
  row.each.with_index do |value, j|
    if field[j][i] >= 2
      count += 1
    end
  end
end

puts "#{count} safe spots"

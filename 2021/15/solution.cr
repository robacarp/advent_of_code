require "colorize"
require "big"

TESTING = true

data = if TESTING
  File.read_lines("testing.txt")
else
  File.read_lines("input.txt")
end

def yolo(*args)
  if TESTING
    puts *args
  end
end

struct Point
  property x : Int32
  property y : Int32

  def initialize(@x, @y)
  end

  def ==(other)
    x == other.x && y == other.y
  end

  def to_s(io : IO)
    io << '('
    io << x
    io << ','
    io << y
    io << ')'
  end

  def clone
    self.class.new x, y
  end

  def <=>(other)
    hash <=> other.hash
  end

  def hash
    x*y
  end
end

class Location
  property total_cost : Int32
  property value : Int32
  property visited : Bool

  def initialize(@value)
    @visited = false
    @total_cost = 0
    @total_cost_set = false
  end

  def total_cost=(val : Int32)
    if @total_cost_set
      if total_cost > val
        @total_cost = val
      end
    else
      @total_cost = val
    end

    @total_cost_set = true
  end

  def to_s(io : IO)
    if visited
      io << value.to_s(precision: 2).colorize.green
    else
      io << value.to_s(precision: 2)
    end
  end

  def clone
    self.class.new(value)
  end
end

class Survivor
  getter data
  getter width : Int32
  getter height : Int32

  getter destination : Point

  def initialize(@data : Array(Array(Location)))
    @width = data.first.size
    @height = data.size
    @destination = Point.new(@width - 1, @height - 1)
  end

  def go_forth()
    distances = Hash(Int32,Array(Point)).new
    infinity = width * height

    [0, infinity].each do |n|
      distances[n] = Array(Point).new
    end

    start = Point.new(0,0)
    distances[0] << start
    self[start].total_cost = 0

    each_point do |x,y|
      distances[infinity] << Point.new(x,y)
    end

    loop do
      break if distances.empty?

      distance = distances.keys.min
      points = distances[distance]

      position = points.shift
      distances.delete distance if points.none?

      location = self[position]
      next if location.visited
      location.visited = true

      {
        Point.new(position.x + 1, position.y),
        Point.new(position.x, position.y + 1),
        Point.new(position.x - 1, position.y),
        Point.new(position.x, position.y - 1),
      }.each do |point|
        next if point.x >= width || point.y >= height || point.x < 0 || point.y < 0

        calculated_distance = distance + self[point].value
        distances[calculated_distance] ||= Array(Point).new
        distances[calculated_distance] << point

        self[point].total_cost = calculated_distance
      end
    end

    finish = Point.new(width-1, height-1)

    self[finish].total_cost
  end

  def each_point
    @data.each.with_index do |row, y|
      row.each.with_index do |value, x|
        yield x,y,value
      end
    end
  end

  def [](p : Point) ; @data[p.y][p.x] ; end
  def [](x,y) ; @data[y][x] ; end
  def []=(x,y,v) ; @data[y][x] = v ; end

  def to_s(io : IO)
    each_point do |x, y, value|
      io << '\n' if x == 0 && y > 0
      io << value
      io << ' '
    end
  end
end

d = data.map do |row|
  row.split("")
    .map(&.to_i)
    .map {|i| Location.new i }
end

survivor = Survivor.new d

duration = Time.measure do
  solution = survivor.go_forth
  puts "Least cost path to solution: #{solution}"
end

puts "(took #{duration})"

puts "="*80
puts "Expanding..."

width = data.first.size
height = data.size

d5 = Array(Array(Location)).new(height * 6) do 
  Array(Location).new(width * 6) do
    Location.new(0)
  end
end

d.each.with_index do |row, i|
  row.each.with_index do |location, j|
    d5[i][j] = location.dup

    (0..5).each do |multiplier|
      (0..5).each do |j_multiplier|
        new_location = location.clone.tap{|l| l.value += multiplier + j_multiplier}
        if new_location.value > 9
          new_location.value = new_location.value % 9
        end

        d5[i + j_multiplier * height][j + multiplier * width] = new_location
      end
    end
  end
end

puts "="*80

survivor = Survivor.new d5
duration = Time.measure do
  solution = survivor.go_forth
  puts "Least cost path to solution: #{solution}"
end

puts "(took #{duration})"

yolo survivor


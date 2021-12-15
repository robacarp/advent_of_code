require "colorize"
require "big"

TESTING = false

data = if TESTING
  File.read_lines("testing2.txt")
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

  def initialize(@value)
    @chosen = false
    @total_cost = 0
    @total_cost_set = false
  end

  def total_cost=(val : Int32)
    if @total_cost_set
      @total_cost = [total_cost, val].min
    else
      @total_cost = val
    end

    @total_cost_set = true
  end

  def to_s(io : IO)
    io << total_cost.to_s(precision: 2)
  end

  def inspect(io : IO)
    io << value.to_s(precision: 2)
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
    visited = [] of Point
    infinity = width * height

    [0, infinity].each do |n|
      distances[n] = [] of Point
    end

    distances[0] << Point.new(0,0)

    each_point do |x,y|
      distances[infinity] << Point.new(x,y)
    end

    loop do
      break if distances.empty?

      distance, points = distances.min

      position = points.shift
      distances.delete distance if points.none?

      next if visited.includes? position

      # yolo "at #{distance}, chose #{position} "
      visited << position

      options = [
        Point.new(position.x + 1, position.y),
        Point.new(position.x, position.y + 1),
        Point.new(position.x - 1, position.y),
        Point.new(position.x, position.y - 1),
      ].reject do |point|
        point.x >= width || point.y >= height || point.x < 0 || point.y < 0
      end

      # yolo "calculating distances for #{options}"

      next if options.none?

      options.each do |point|
        calculated_distance = distance + self.[point].value
        distances[calculated_distance] ||= [] of Point
        distances[calculated_distance] << point

        self[point].total_cost = calculated_distance
      end
    end

    finish = Point.new(width-1,height-1)

    self[finish]
  end

  def mark(path : Array(Point))
    path.each do |point|
      self.[point].chosen = true
    end
  end

  def each_point
    @data.each.with_index do |row, y|
      row.each.with_index do |value, x|
        yield x,y
      end
    end
  end

  def [](p : Point) ; @data[p.y][p.x] ; end
  def [](x,y) ; @data[y][x] ; end
  def []=(x,y,v) ; @data[y][x] = v ; end

  def to_s(io : IO)
    @data.each.with_index do |row, y|
      row.each.with_index do |value, x|
        io << value
        io << ' '
      end
      io << '\n'
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

# yolo survivor
puts "="*80

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
        new_location = location.dup.tap{|l| l.value += multiplier + j_multiplier}
        if new_location.value > 9
          new_location.value = new_location.value % 9
        end

        d5[i + j_multiplier * height][j + multiplier * width] = new_location
      end
    end
  end
end

survivor = Survivor.new d5
solution = survivor.go_forth
puts "Least cost path to solution: #{solution}"

require "colorize"
require "big"

TESTING = false

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
  property path : Array(self)
  property total_cost : Int32

  def initialize(@x, @y)
    @path = [] of self
    @total_cost = Int32::MAX
  end

  def total_cost=(val : Int32)
    @total_cost = val if @total_cost > val
  end

  def ==(other)
    x == other.x && y == other.y
  end

  def to_s(io : IO)
    io << '('
    io << x
    io << ','
    io << y
    if total_cost < Int32::MAX
      io << ' '
      io << total_cost
    end
    io << ')'
  end

  delegate inspect, to: to_s

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
  property arrival_cost : Int32
  property value : Int32
  property visited : Bool
  property path : Array(Point)

  def initialize(@value)
    @visited = false
    @arrival_cost = Int32::MAX
    @path = [] of Point
  end

  def cost_s(io : IO)
    if visited
      io << arrival_cost.to_s(precision: 2).colorize.green
    else
      io << arrival_cost.to_s(precision: 2)
    end
  end

  def value_s(io : IO)
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

class Queue(IndexT, ValueT)
  def initialize
    @data = Hash(IndexT, Array(ValueT)).new { |h,k| h[k] = [] of ValueT }
    @keys_with_data = Set(IndexT).new
  end

  def pop : Tuple(IndexT, ValueT)?
    first_key = @keys_with_data.min?

    return nil unless first_key
    value = @data[first_key].shift

    @keys_with_data.delete first_key if @data[first_key].none?

    {first_key, value}
  end

  def insert(value : ValueT, at position : IndexT)
    @keys_with_data << position
    @data[position] << value
  end
end

class Survivor
  getter data
  getter width : Int32
  getter height : Int32

  def initialize(@data : Array(Array(Location)))
    @width = data.first.size
    @height = data.size
  end

  def go_forth()
    queue = Queue(Int32, Point).new
    infinity = Int32::MAX - 1

    start = Point.new(0,0)
    queue.insert start, at: 0
    self[start].arrival_cost = 0

    each_point do |x,y|
      queue.insert Point.new(x,y), at: infinity
    end

    loop do
      pop = queue.pop
      break unless pop

      distance, position = pop

      location = self[position]
      next if location.visited

      # yolo "at d=#{distance}, p=#{position}, path: #{position.path}"

      location.visited = true
      location.arrival_cost = distance
      # location.path = position.path.dup
      # location.path << position

      {
        Point.new(position.x + 1, position.y),
        Point.new(position.x, position.y + 1),
        Point.new(position.x - 1, position.y),
        Point.new(position.x, position.y - 1),
      }.each do |point|
        next if point.x >= width || point.y >= height || point.x < 0 || point.y < 0

        # point.path = position.path.dup
        # point.path << position

        calculated_distance = distance + self[point].value
        queue.insert point, at: calculated_distance
      end
    end
  end

  def finish
    self[Point.new(width-1, height-1)]
  end

  def each_point
    @data.each.with_index do |row, y|
      row.each.with_index do |location, x|
        yield x,y,location
      end
    end
  end

  def mark_path(path : Array(Point))
    each_point do |_,_,location|
      location.visited = false
    end

    path.each do |point|
      self[point].visited = true
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

  def cost_map
    String.build do |io|
      each_point do |x, y, location|
        io << '\n' if x == 0 && y > 0
        location.cost_s(io)
        io << ' '
      end
    end
  end

  def value_map
    String.build do |io|
      each_point do |x, y, location|
        io << '\n' if x == 0 && y > 0
        location.value_s(io)
        io << ' '
      end
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
  survivor.go_forth
end

finish = survivor.finish
puts "Least cost to solution: #{finish.arrival_cost}"

puts "(took #{duration})"
# survivor.mark_path finish.path

yolo survivor.value_map
yolo "="*8
yolo survivor.cost_map

puts "="*80
puts "Expanding..."

width = data.first.size
height = data.size

d5 = Array(Array(Location)).new(height * 5) do 
  Array(Location).new(width * 5) do
    Location.new(0)
  end
end

d.each.with_index do |row, i|
  row.each.with_index do |location, j|
    d5[i][j] = location.clone

    (0...5).each do |multiplier|
      (0...5).each do |j_multiplier|
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
  survivor.go_forth
end

finish = survivor.finish
puts "Least cost to solution: #{finish.arrival_cost}"
# yolo "Path: #{finish.path}"

puts "(took #{duration})"

# survivor.mark_path finish.path

yolo survivor.value_map
yolo survivor.cost_map

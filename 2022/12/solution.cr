require "../helper"

sample = <<-TEXT
Sabqponm
abcryxxl
accszExk
acctuvwj
abdefghi
TEXT

class Location
  property cost : Int32
  property value : Char
  property visited : Bool
  property x : Int32
  property y : Int32

  def initialize(@x, @y, @value = ('z'.ord + 1).chr)
    @visited = false
    @cost = Int32::MAX
  end

  def cost_s(io : IO)
    if cost == Int32::MAX
      io << "  "
    else
      io << cost.to_s(precision: 2)
    end
  end

  def neighbors : Array(self)
    [
      self.class.new(x + 1, y),
      self.class.new(x, y + 1),
      self.class.new(x - 1, y),
      self.class.new(x, y - 1),
    ]
  end

  def value_s(io : IO)
    color = :default
    color = :green if visited
    color = :red if value == 'E'
    io << value.to_s.colorize(color)
  end

  def ==(other)
    x == other.x && y == other.y
  end

  def inspect(io)
    io << "<" << x << "," << y << "="
    value_s io
    io << ">"
  end

  def calculated_value
    case value
    when 'S' then 'a'
    when 'E' then 'z'
    else
      value
    end
  end

  def delta_v(other : self)
    self.calculated_value - other.calculated_value
  end
end

class Queue(IndexT, ValueT)
  def initialize
    @data = Hash(IndexT, Array(ValueT)).new { |h, k| h[k] = [] of ValueT }
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

  def visually_inspect
    String.build do |b|
      @keys_with_data.each do |key|
        b << key.to_s << "(" << @data[key].size.to_s << ") :"
        @data[key].first(5).each do |location|
          b << location.inspect << ", "
        end
        b << "\n"
      end
    end
  end
end

class HillClimb
  getter map : Array(Array(Location))
  getter width : Int32
  getter height : Int32
  property start : Location { Location.new(0, 0) }
  property finish : Location { Location.new(0, 0) }

  getter safe_to_step : Proc(Char, Char, Bool) = ->(from_height : Char, to_height : Char) { from_height == to_height }

  def initialize(input, @safe_to_step)
    @map = input.lines.map_with_index { |line, y|
      line.chars.map_with_index do |char, x|
        Location.new(x, y, char).tap do |location|
          if location.value == 'S'
            @start = location
          elsif location.value == 'E'
            @finish = location
          end
        end
      end
    }

    @width = map.first.size
    @height = map.size
  end

  def each_location
    @map.each.with_index do |row, y|
      row.each.with_index do |location, x|
        yield x, y, location
      end
    end
  end

  def [](p : Location)
    @map[p.y][p.x]
  end

  def [](x, y)
    @map[y][x]
  end

  def []=(x, y, v)
    @map[y][x] = v
  end

  def solve
    queue = Queue(Int32, Location).new
    infinity = Int32::MAX - 1

    queue.insert start, at: 0
    self[start].cost = 0

    loop do
      pop = queue.pop
      break unless pop

      _, loc = pop

      location = self[loc]
      next if location.visited

      location.visited = true
      next_cost = location.cost + 1

      location.neighbors
        .reject { |next_location| next_location.x >= width || next_location.y >= height || next_location.x < 0 || next_location.y < 0 }
        .map { |l| self[l] }
        .each do |next_location|
          next if next_location.visited
          next unless safe_to_step.call location.calculated_value, next_location.calculated_value

          next_location.cost = next_cost
          queue.insert next_location, at: next_cost unless next_location.visited
        end

        Log.debug { value_map + "\n" }
    end
  end

  def value_map
    String.build do |io|
      each_location do |x, y, location|
        io << '\n' if x == 0 && y > 0
        location.value_s io
        # location.cost_s io
        io << ' '
      end
    end
  end
end

AOC(Int32)["shortest path from S->E"].do do
  safe_to_step = ->(from : Char, to : Char) {
    # only safe to step if the adjacent location is a climb up of <= 1 -- but climb down of any height is ok
    # puts "from #{from.inspect} to #{to.inspect}"
    to - from <= 1
  }

  hill_climb = HillClimb.new sample, safe_to_step
  hill_climb.solve
  assert_equal 31, hill_climb.finish.cost

  solve do
    hill_climb = HillClimb.new input, safe_to_step
    hill_climb.solve
    solution hill_climb.finish.cost
  end
end

AOC(Int32)["shortest path from a->E"].do do
  safe_to_step = ->(from : Char, to : Char) {
    # working backwards this time, it's ok to climb any hill but only down a cliff of height 1
    from - to <= 1
  }

  trail_finder = HillClimb.new sample, safe_to_step
  trail_finder.start = trail_finder.finish
  trail_finder.solve

  location_of_as = trail_finder.map.flatten.select { |l| l.calculated_value == 'a' }

  closest_a = location_of_as.map(&.cost).min
  assert_equal 29, closest_a

  solve do
    trail_finder = HillClimb.new input, safe_to_step
    trail_finder.start = trail_finder.finish
    trail_finder.solve

    location_of_as = trail_finder.map.flatten.select { |l| l.calculated_value == 'a' }
    closest_a = location_of_as.map(&.cost).min

    solution closest_a
  end
end

require "../helper"
require "colorize"

sample = <<-TEXT
498,4 -> 498,6 -> 496,6
503,4 -> 502,4 -> 502,9 -> 494,9
TEXT

struct Point
  getter x, y

  def initialize(@x : Int32, @y : Int32)
  end

  def move_by(dx : Int32, dy : Int32)
    @x += dx
    @y += dy
  end

  def move_to(p : self)
    @x = p.x
    @y = p.y
  end

  def ==(other : Point)
    @x == other.x && @y == other.y
  end

  def ==(other : Tuple(Int32, Int32))
    @x == other.first && @y == other.last
  end

  def max(other : Point)
    @x = other.x if @x < other.x
    @y = other.y if @y < other.y
  end

  def min(other : Point)
    @x = other.x if @x > other.x
    @y = other.y if @y > other.y
  end

  def downpath
    [
      self.class.new(@x, @y + 1),
      self.class.new(@x - 1, @y + 1),
      self.class.new(@x + 1, @y + 1)
    ]
  end

  def to_s(io)
    io << "(#{x}, #{y})"
  end
end


class Sand
  getter matrix = Array(Array(Char)).new(1000) { Array(Char).new(1000) { '.' } }
  getter min = Point.new(1000, 1000)
  getter max = Point.new(0, 0)
  getter floor_y = -1

  def [](p : Point) : Char
    @matrix[p.y][p.x]
  end

  def []=(p : Point, v : Char)
    @matrix[p.y][p.x] = v
  end

  def [](x, y)
    @matrix[y][x]
  end

  def []=(x, y, v)
    @matrix[y][x] = v
  end

  def initialize(input)
    input.lines.each do |line|
      points = line.split("->").map do |x_y|
        x, y = x_y.split(",").map &.to_i
        Point.new x, y
      end

      current_point = next_point = points.pop

      while true
        # puts "current_point: #{current_point}"
        self[current_point.x, current_point.y] = '#'

        min.min current_point
        max.max current_point

        if current_point == next_point
          next_point = points.pop? || break
        end

        if current_point.x < next_point.x
          current_point.move_by 1, 0
        elsif current_point.x > next_point.x
          current_point.move_by -1, 0
        elsif current_point.y < next_point.y
          current_point.move_by 0, 1
        elsif current_point.y > next_point.y
          current_point.move_by 0, -1
        end
      end
    end
  end

  def drip(from : Point) : Bool
    # if the dripper is blocked
    return false if self[from] == 'o'

    grain = from.dup

    while true
      grain_was = grain.dup

      grain.downpath.each do |p|
        next if p.y > max.y || p.x < 0 || p.y < 0
        next if p.y == floor_y

        if self[p] == '.'
          grain.move_to p
          break
        end
      end

      # if it didn't move
      break if grain_was == grain

      # if it falls off the map
      return false if from.y > max.y

      max.max grain
      min.min grain
    end

    # debug grain
    # sleep 0.1

    self[grain] = 'o'

    true
  end

  def make_floor_at(y : Int32)
    @floor_y = y
    max.max Point.new(0, y)
  end

  def debug(drop_point : Point? = nil)
    (min.y..max.y).to_a.each do |y|
      (min.x..max.x).each do |x|
        point = self[x, y]
        color = point == '#' ? :green : :white

        if point_ = drop_point
          if point_ == {x, y}
            color = :red
            point = 'o'
          end
        end

        if y == floor_y
          color = :blue
          point = '#'
        end

        print point.to_s.colorize(color)
      end
      puts
    end
  end

end

AOC(Int32)["grains of sand contained"].do do
  sandy_sand = Sand.new(sample)
  caught_drips = 0

  fountain = Point.new 500, 0
  while sandy_sand.drip(fountain)
    caught_drips += 1
  end

  assert_equal 24, caught_drips

  solve do
    caught_drips = 0
    sandy_sand = Sand.new(input)

    while sandy_sand.drip(fountain)
      caught_drips += 1
    end

    solution caught_drips
  end
end

AOC(Int32)["grains of sand contained"].do do
  caught_drips = 0
  sandy_sand = Sand.new(sample)
  sandy_sand.make_floor_at sandy_sand.max.y + 2
  sandy_sand.debug

  fountain = Point.new 500, 0
  while sandy_sand.drip(fountain)
    caught_drips += 1
  end

    sandy_sand.debug
  assert_equal 93, caught_drips

  solve do
    caught_drips = 0
    sandy_sand = Sand.new(input)
    sandy_sand.make_floor_at sandy_sand.max.y + 2

    while sandy_sand.drip(fountain)
      caught_drips += 1
    end
    sandy_sand.debug

    solution caught_drips
  end
end

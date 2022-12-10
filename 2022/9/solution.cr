require "../helper"
require "colorize"

sample = <<-TEXT
R 4
U 4
L 3
D 1
R 4
D 1
L 5
R 2
TEXT

sample2 = <<-TEXT
R 5
U 8
L 8
D 3
R 17
D 10
L 25
U 20
TEXT

class Point
  property x : Int32
  property y : Int32

  def self.[](x, y)
    new x: x, y: y
  end

  def initialize(@x, @y)
  end

  def move_by(other : Point)
    @x += other.x
    @y += other.y
  end

  def clamp(magnitude : Int32)
    @x = @x.clamp -magnitude, magnitude
    @y = @y.clamp -magnitude, magnitude
  end

  def -(other : Point) : self
    self.class[other.x - x, other.y - y]
  end

  def to_s(io)
    io << "(#{x}, #{y})"
  end
end

class Problem
  @moves = Array(Tuple(String, Int32)).new

  getter tail_positions : Array(Point)
  getter tail : Array(Point)

  def initialize(input, tail_size)
    input.lines.each do |line|
      direction, distance = line.chomp.split(" ")
      @moves << {direction, distance.to_i}
    end

    @tail = Array(Point).new(tail_size) do
      Point.new(0, 0)
    end

    @tail_positions = Array(Point).new
    @previous_knot = Point.new(0, 0)
  end

  def solve
    # debug

    @moves.each.with_index do |(direction, magnitude), index|
      # puts "direction: #{direction}, magnitude: #{magnitude}"

      magnitude.times do
        move direction
        drag_tail
        # debug
      end

    end

    tail_positions.uniq {|p| "x=#{p.x}y=#{p.y}" }.size
  end

  def move(direction)
    case direction
    when "R" then tail[0].x += 1
    when "L" then tail[0].x -= 1
    when "U" then tail[0].y += 1
    when "D" then tail[0].y -= 1
    end
  end

  def drag_tail
    tail.each_with_index.skip(1).each do |knot, i|
      previous_knot = tail[i - 1]

      shift = knot - previous_knot
      next unless shift.x.abs > 1 || shift.y.abs > 1

      shift.clamp 1

      knot.move_by shift
    end

    tail_positions << tail[-1].dup
  end

  def debug
    min_x, max_x = (tail.map(&.x) + tail_positions.map(&.x)).push(0, 10).minmax
    min_y, max_y = (tail.map(&.y) + tail_positions.map(&.y)).push(0, 10).minmax

    (min_y..max_y).to_a.reverse.each do |y|
      if y < 0
        print (10 - y % 10).colorize.red
      else
        print y % 10
      end

      print ' '

      (min_x..max_x).each do |x|
        color = :default

        if tail_positions.any? { |n| n.x == x && n.y == y }
          color = :green
        end

        symbol = "╬"

        if tail[0].x == x && tail[0].y == y
          symbol = "H"
        elsif (n = tail[1..].count { |n| n.x == x && n.y == y }) > 0
          symbol = n.to_s
        elsif x == 0 && y == 0
          symbol = "S"
        end

        print symbol.colorize(color)
      end
      puts
    end

    print "  "

    (min_x..max_x).each do |x|
      if x < 0
        print (10 - x % 10).colorize.red
      else
        print x % 10
      end
    end

    puts 
    puts ">========<"
  end

end

AOC(Int32)["tail covers places"].do do
  tail_size = 2
  assert_equal 13, Problem.new(sample, tail_size).solve

  solve do
    solution Problem.new(input, tail_size).solve
  end
end

AOC(Int32)["tail covers places"].do do
  tail_size = 10
  assert_equal 36, Problem.new(sample2, tail_size).solve

  solve do
    solution Problem.new(input, tail_size).solve
  end
end

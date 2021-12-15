require "colorize"
require "big"

TESTING = true

data = if TESTING
  File.read_lines("testing2.txt")
else
  File.read_lines("input.txt")
end

macro yolo(*args)
  # if false && TESTING
  #   puts *args
  # end
end

class Point
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
end

class Location
  property chosen : Bool
  property value : Int32

  def initialize(@value)
    @chosen = false
  end

  def to_s(io : IO)
    if chosen
      io << value.colorize.red
    else
      io << value
    end
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

  def go_forth(position = Point.new(0,0), path = [] of Point) : Tuple(Int32, Array(Point))?
    path << position
    puts path.size

    if position == destination# || path.size > 28
      cost = path.map do |point|
        self.[point].value
      end.sum

      return {cost, path}
    end

    options = [
      Point.new(position.x + 1, position.y),
      Point.new(position.x, position.y + 1),
      # Point.new(position.x - 1, position.y),
      # Point.new(position.x, position.y - 1),
    ].reject do |point|
      point.x >= width || point.y >= height || point.x < 0 || point.y < 0
    end.reject { |point| path.includes? point }

    return if options.none?

    yolo "[#{position}] #{options.size} options: #{options.map(&.to_s).join("-".colorize.red)}"

    option_paths = options.map do |next_position|
      go_forth next_position, path.clone
    end
      .compact
      .sort_by { |(cost, _)| cost }

    return if option_paths.none?

    # yolo "path here (#{cost.colorize.green}):"
    # yolo path
    # yolo "sorted paths:"

    # option_paths.each do |option_path|
    #   yolo option_path.first.colorize.green
    #   yolo option_path.last - path
    #   yolo
    # end

    return option_paths.first
  end

  def mark(path : Array(Point))
    path.each do |point|
      self.[point].chosen = true
    end
  end

  def [](p : Point) ; @data[p.y][p.x] ; end
  def [](x,y) ; @data[y][x] ; end
  def []=(x,y,v) ; @data[y][x] = v ; end

  def to_s(io : IO)
    width.times do |x|
      io << x.to_s(16)
    end
    io << '\n'

    @data.each.with_index do |row, y|
      row.each.with_index do |value, x|
        io << value
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
solution = survivor.go_forth

puts "="*80

if solution_ = solution
  cost, path = solution_
  survivor.mark path
  puts cost.colorize.green
  puts path
  puts survivor
else
  puts "no solution found"
end

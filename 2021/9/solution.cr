lines = File.read_lines("testing.txt")
lines = File.read_lines("input.txt")

data = lines.map(&.split("")).map {|line| line.map(&.to_i) }

# pp data

struct Point
  property x : Int32
  property y : Int32
  property value : Int32

  def initialize(@x, @y, @value = 0)
  end

  def ==(other)
    x == other.x && y == other.y
  end
end

class Map
  getter data
  getter low_points
  getter width : Int32
  getter height : Int32

  def initialize(@data : Array(Array(Int32)))
    @low_points = [] of Point
    @width = data[0].size - 1
    @height = data.size - 1
  end

  def find_low_points
    data.each.with_index do |row, y|
      row.each.with_index do |point, x|
        next unless row[x - 1] > point if x > 0
        next unless row[x + 1] > point if x < width
        next unless data[y - 1][x] > point if y > 0
        next unless data[y + 1][x] > point if y < height

        @low_points << Point.new(x,y, point)
      end
    end
  end

  def [](x : Int32, y : Int32) ; data[y][x] ; end
  def [](point : Point) ; data[point.x, point.y] ; end
end

struct BasinFinder
  getter basin
  getter map

  def initialize(local_min : Point, @map : Map)
    @basin = [] of Point
    expand(local_min)
  end

  def expand(point)
    return false if point.y > map.height || point.y < 0
    return false if point.x > map.width || point.x < 0
    return false if map[point.x, point.y] >= 9
    return false if basin.includes? point

    @basin << point

    expand Point.new(point.x + 1, point.y)
    expand Point.new(point.x - 1, point.y)
    expand Point.new(point.x, point.y + 1)
    expand Point.new(point.x, point.y - 1)
  end
end

map = Map.new data
map.find_low_points

puts "sum of local-low-risks: #{map.low_points.map(&.value).map(&.+(1)).sum}"

puts "-"*80

biggest_basins = map.low_points.map do |low_point|
  BasinFinder.new(low_point, map).basin.size
end.sort.last(3)

puts "product of 3 biggest basins: #{biggest_basins.reduce(1) {|a, i| a * i}}"

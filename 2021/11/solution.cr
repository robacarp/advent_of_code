require "colorize"

data = File.read_lines("testing2.txt")
data = File.read_lines("testing.txt")
data = File.read_lines("input.txt")

class Octopodes
  getter width : Int32, height : Int32
  getter flash_count = 0
  getter step_count = 0
  getter all_flashed = [] of Int32

  VIDEO = false
  SLEEP = 0

  def initialize(@data : Array(Array(Int32)))
    @width = @data.first.size
    @height = @data.size
  end

  def all
    @data.each.with_index do |row, y|
      row.each.with_index do |octopus, x|
        yield x,y
      end
    end
  end

  def bloop
    @step_count += 1

    all do |x, y|
      self.[x,y] += 1
    end

    if VIDEO
      puts self
      sleep SLEEP
    end

    rebloop
    check_for_allflash
  end

  def check_for_allflash
    nonflashy = false
    all do |x,y|
      nonflashy = true unless self.[x,y] == 0
    end

    return if nonflashy
    @all_flashed << step_count
  end

  def rebloop
    loop do
      changed = false
      reference = self.clone

      all do |x, y|
        if reference.[x,y] > 9
          changed = true
          @flash_count += 1
          self.[x,y] = 0
          cascade x, y
        end
      end

      if VIDEO
        puts self
        sleep SLEEP
      end

      break unless changed
    end
  end

  def clone
    self.class.new(@data.clone)
  end

  def cascade(x,y)
    increment_sometimes(x, y - 1) if y > 0
    increment_sometimes(x, y + 1) if y < height - 1
    increment_sometimes(x - 1, y) if x > 0
    increment_sometimes(x + 1, y) if x < width - 1

    increment_sometimes(x - 1, y - 1) if x > 0 && y > 0
    increment_sometimes(x - 1, y + 1) if x > 0 && y < height - 1
    increment_sometimes(x + 1, y - 1) if x < width - 1 && y > 0
    increment_sometimes(x + 1, y + 1) if x < width - 1 && y < height - 1
  end

  def increment_sometimes(x,y)
    self.[x,y] += 1 if self.[x,y] > 0
  end

  def [](x,y) ; @data[y][x] ; end
  def []=(x,y,v) ; @data[y][x] = v ; end

  def to_s(io : IO)
    @data.each.with_index do |row, y|
      row.each.with_index do |octopus, x|
        if octopus == 0
          # io << octopus.colorize.mode(:bold)
          io << octopus.colorize.green
        elsif octopus > 9
          io << '*'.colorize.red
        else
          io << octopus
        end
      end
      io << '\n'
    end
  end
end

blank = [
  [0,0,0,0,0,0,0,0,0,0],
  [0,0,0,0,0,0,0,0,0,0],
  [0,0,0,0,0,0,0,0,0,0],
  [0,0,0,0,0,0,0,0,0,0],
  [0,0,0,0,0,0,0,0,0,0],
  [0,0,0,0,0,0,0,0,0,0],
  [0,0,0,0,0,0,0,0,0,0],
  [0,0,0,0,0,0,0,0,0,0],
  [0,0,0,0,0,0,0,0,0,0],
  [0,0,0,0,0,0,0,0,0,0],
]

data = data.map do |row|
  row.split("").map(&.to_i)
end

octopii = Octopodes.new(data)


loop do
  octopii.bloop
  break if octopii.all_flashed.any?
end

puts "Octopodes flashed #{octopii.flash_count}"
puts "All of them flashed at #{octopii.all_flashed}"

require "colorize"

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


class Paper
  @data : Array(Array(Bool))
  getter width : Int32, height : Int32

  def initialize(@width, @height)
    @data = Array(Array(Bool)).new(width + 1) do
      Array(Bool).new(height + 1, false)
    end
  end

  def dot(x,y)
    @data[x][y] = true
  end

  def x_fold(i)
    yolo "x_fold #{i}"

    (width - i + 1).times do |x|
      yolo "assigning from #{i+x} to #{i-x}"
      0.upto(height).each do |y|
        @data[i - x][y] ||= @data[i+x][y]
      end
    end

    @width = (@width // 2) - 1
    yolo
  end

  def y_fold(i)
    yolo "y_fold #{i}"

    (height - i + 1).times do |y|
      yolo "assigning from #{i+y} to #{i-y}"
      0.upto(width).each do |x|
        @data[x][i - y] ||= @data[x][i + y]
      end
    end

    @height = (@height // 2) - 1
    yolo
  end

  def count
    dots = 0

    0.upto(height).each do |y|
      0.upto(width).each do |x|
        dots += 1 if @data[x][y]
      end
    end

    dots
  end

  def to_s(io : IO)
    io << "   "
    0.upto(width).each do |x|
      io << x.to_s(16)
    end
    io << '\n'

    0.upto(height).each do |y|
      io << y.to_s precision: 2
      io << ' '
      0.upto(width).each do |x|
        if @data[x][y]
          io << '#'.colorize.light_gray
        else
          io << '.'.colorize.dark_gray
        end
      end
      io << '\n'
    end
  end
end

folds = data.select {|line| line.starts_with? "fold"}
dots = data.select {|line| line.includes? ','}

pairs = dots.map(&.split(',').map(&.to_i))
max_height = pairs.map(&.last).max
max_width = pairs.map(&.first).max

yolo "x max: #{max_width}"
yolo "y max: #{max_height}"
yolo

paper = Paper.new(max_width, max_height)

pairs.each do |(x,y)|
  paper.dot(x,y)
end

yolo paper

folds.each do |fold|
  direction, location = fold.split '='
  direction = direction[-1]
  location = location.to_i

  case direction
  when 'x' then paper.x_fold location
  when 'y' then paper.y_fold location
  else
    raise "can't fold '#{direction}'"
  end
end

yolo paper
puts "#{paper.count} dots"
puts paper

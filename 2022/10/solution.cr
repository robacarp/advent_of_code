require "../helper"

sample = <<-TEXT
addx 15
addx -11
addx 6
addx -3
addx 5
addx -1
addx -8
addx 13
addx 4
noop
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx -35
addx 1
addx 24
addx -19
addx 1
addx 16
addx -11
noop
noop
addx 21
addx -15
noop
noop
addx -3
addx 9
addx 1
addx -3
addx 8
addx 1
addx 5
noop
noop
noop
noop
noop
addx -36
noop
addx 1
addx 7
noop
noop
noop
addx 2
addx 6
noop
noop
noop
noop
noop
addx 1
noop
noop
addx 7
addx 1
noop
addx -13
addx 13
addx 7
noop
addx 1
addx -33
noop
noop
noop
addx 2
noop
noop
noop
addx 8
noop
addx -1
addx 2
addx 1
noop
addx 17
addx -9
addx 1
addx 1
addx -3
addx 11
noop
noop
addx 1
noop
addx 1
noop
noop
addx -13
addx -19
addx 1
addx 3
addx 26
addx -30
addx 12
addx -1
addx 3
addx 1
noop
noop
noop
addx -9
addx 18
addx 1
addx 2
noop
noop
addx 9
noop
noop
noop
addx -1
addx 2
addx -37
addx 1
addx 3
noop
addx 15
addx -21
addx 22
addx -6
addx 1
noop
addx 2
addx 1
noop
addx -10
noop
noop
addx 20
addx 1
addx 2
addx 2
addx -6
addx -11
noop
noop
noop
TEXT

# You count the pixels on the CRT: 40 wide and 6 high. This CRT screen draws
# the top row of pixels left-to-right, then the row below that, and so on. The
# left-most pixel in each row is in position 0, and the right-most pixel in
# each row is in position 39.

# Like the CPU, the CRT is tied closely to the clock circuit: the CRT draws a
# single pixel during each cycle. Representing each pixel of the screen as a #,
# here are the cycles during which the first and last pixel in each row are
# drawn:

# Cycle   1 -> ######################################## <- Cycle  40
# Cycle  41 -> ######################################## <- Cycle  80
# Cycle  81 -> ######################################## <- Cycle 120
# Cycle 121 -> ######################################## <- Cycle 160
# Cycle 161 -> ######################################## <- Cycle 200
# Cycle 201 -> ######################################## <- Cycle 240


class Compy7070
  getter input : String
  getter tickset : Array(Int32)
  getter tickset_values : Array(Int32)

  def initialize(@input, @tickset)
    @tick = 0
    @x = 1
    @tickset_values = [] of Int32

    @gpu_pixel = 0
    @gpu = Array(String).new(240) { "|" }
  end

  def solve
    lines = input.lines

    while line = lines.shift?
      next step if line == "noop"
      step
      step
      _, amount = line.split " "
      @x += amount.to_i
    end
  end

  def step
    @tick += 1
    if tickset.includes? @tick
      @tickset_values << @x * @tick
    end

    if [-1,0,1].includes?(@gpu_pixel % 40 - @x)
      @gpu[@gpu_pixel] = "#"#.colorize(:green).to_s
    else
      @gpu[@gpu_pixel] = "."
    end

    @gpu_pixel += 1
    @gpu_pixel = 0 if @gpu_pixel > 239
  end

  def screen : String
    String.build do |io|
      @gpu.each_slice 40 do |row|
        io << row.join
        io << '\n'
      end
    end
  end
end

AOC(Int32)["signal strength"].do do
  offsets = [20, 60, 100, 140, 180, 220]
  compy = Compy7070.new sample, offsets
  compy.solve
  assert_equal 13140, compy.tickset_values.sum

  solve do
    compy = Compy7070.new input, offsets
    compy.solve
    solution compy.tickset_values.sum
  end
end

AOC(String)["screen"].do do
  compy = Compy7070.new sample, [] of Int32
  compy.solve

  expected = <<-TEXT
  ##..##..##..##..##..##..##..##..##..##..
  ###...###...###...###...###...###...###.
  ####....####....####....####....####....
  #####.....#####.....#####.....#####.....
  ######......######......######......####
  #######.......#######.......#######.....

  TEXT

  assert_equal(expected, compy.screen)

  solve do
    compy = Compy7070.new input, [] of Int32
    compy.solve
    solution compy.screen
  end
end

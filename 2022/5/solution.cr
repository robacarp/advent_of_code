require "../helper"

sample = <<-TEXT
    [D]
[N] [C]
[Z] [M] [P]
 1   2   3

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2
TEXT

class CrateStacks
  def self.build_stacks(data : String) : self
    crate_state = [] of String
    lines = data.lines
    while line = lines.shift
      break if line.blank?
      crate_state << line
    end

    numbers = crate_state.pop
    num_stacks = numbers.split(/\s+/).reject(&.blank?).sort.last.to_i
    stacks = new(num_stacks, lines)

    crate_state.each do |line|
      line.chars.each_slice(4).with_index do |crate, index|
        letter = crate[1]
        next if letter == ' '
        stacks.stack letter, on: index.+(1)
      end
    end

    stacks
  end

  def initialize(number_of_stacks : Int32, @move_instructions : Array(String))
    @stacks = Hash(Int32, Array(Char)).new do |h,k|
      h[k] = [] of Char
    end
  end

  def stack(letter, on index)
    @stacks[index].unshift letter
  end

  def run_moves(fancy = false)
    @move_instructions.each do |command|
      matchdata = command.match /move (\d+) from (\d+) to (\d+)/
      raise "command match failed: #{command}" if matchdata.nil?
      count = matchdata[1].to_i
      from = matchdata[2].to_i
      to = matchdata[3].to_i

      if fancy
        fancymove count, from, to
      else
        move count, from, to
      end
    end
  end

  def move(count, from, to)
    count.times do
      @stacks[to].push @stacks[from].pop
    end
  end

  def fancymove(count, from, to)
    crane = [] of Char
    count.times do
      crane.push @stacks[from].pop
    end

    count.times do
      @stacks[to].push crane.pop
    end
  end

  def tops
    @stacks.keys.sort.map {|k| @stacks[k].last }.join
  end
end

AOC(String)["stack toppers"].do do
  stacks = CrateStacks.build_stacks sample
  stacks.run_moves
  assert_equal "CMZ", stacks.tops

  solve do
    stacks = CrateStacks.build_stacks input
    stacks.run_moves
    solution stacks.tops
  end
end

AOC(String)["stack toppers"].do do
  stacks = CrateStacks.build_stacks sample
  stacks.run_moves fancy: true
  assert_equal "MCD", stacks.tops

  solve do
    stacks = CrateStacks.build_stacks input
    stacks.run_moves fancy: true
    solution stacks.tops
  end
end

require "../helper"

sample = <<-TEXT
TEXT

class Problem
  def initialize(input)
    # matrix = data.lines.map(&.chars.map(&.to_i))

    # input.lines.each do |line|
    # end
  end

  def solve
  end
end

AOC(Int32)["title"].do do
  assert_equal 0, Problem.new(sample).solve

  solve do
    # solution Problem.new(input).solve
  end
end

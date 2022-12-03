require "../helper"

sample = <<-TEXT
A Y
B X
C Z
TEXT

class RockPaperScissors
  def initialize(@data : String)
  end

  # a = x = rock
  # b = y = paper
  # c = z = scissors
  POINTS = {
    "A" => 1,
    "B" => 2,
    "C" => 3,

    "X" => 1,
    "Y" => 2,
    "Z" => 3
  }

  def step_1
    hand_score = {
      "AX" => 3,
      "AY" => 6,
      "AZ" => 0,

      "BX" => 0,
      "BY" => 3,
      "BZ" => 6,

      "CX" => 6,
      "CY" => 0,
      "CZ" => 3
    }

    score = 0
    @data.lines.map(&.split ' ').each do |(them, me)|
      score += POINTS[me]
      score += hand_score[them + me]
    end
    score
  end

  def step_2
    # x = lose = 0
    # y = draw = 3
    # z = win = 6

    hand_score = {
      # rock
      "AX" => 0 + POINTS["Z"], # lose
      "AY" => 3 + POINTS["X"], # draw
      "AZ" => 6 + POINTS["Y"], # win

      # paper
      "BX" => 0 + POINTS["X"],
      "BY" => 3 + POINTS["Y"],
      "BZ" => 6 + POINTS["Z"],

      # scissors
      "CX" => 0 + POINTS["Y"],
      "CY" => 3 + POINTS["Z"],
      "CZ" => 6 + POINTS["X"]
    }

    score = 0
    @data.lines.map(&.split ' ').each do |(them, me)|
      score += hand_score[them + me]
    end
    score
  end
end

AOC(Int32)["total_score"].do do
  assert_equal 15, RockPaperScissors.new(sample).step_1
  solve do
    solution RockPaperScissors.new(input).step_1
  end
end

AOC(Int32)["total_score"].do do
  assert_equal 12, RockPaperScissors.new(sample).step_2

  solve do
    solution RockPaperScissors.new(input).step_2
  end
end

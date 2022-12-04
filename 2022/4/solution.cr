require "../helper"

sample = <<-TEXT
2-4,6-8
2-3,4-5
5-7,7-9
2-8,3-7
6-6,4-6
2-6,4-8
TEXT

struct Range(B, E)
  def contains_entirely?(other : self) : Bool
    @begin <= other.begin && @end >= other.end
  end

  def any_overlap?(other : self) : Bool
    includes?(other.begin) || includes?(other.end) || other.includes?(@begin) || other.includes?(@end)
  end
end

class CleanupPairs
  def self.make_range(hyphenated : String) : Range(Int32, Int32)
    lower, upper = hyphenated.split '-'
    Range(Int32, Int32).new lower.to_i, upper.to_i
  end

  @pairs = [] of Tuple(Range(Int32, Int32), Range(Int32, Int32))

  def initialize(data : String)
    data.lines.each do |line|
      first, second = line.split(',').map {|job| self.class.make_range job }
      @pairs.push({ first, second })
    end
  end

  def pairs_with_redundancy : Int32
    @pairs.select do |pair|
      pair[0].contains_entirely?(pair[1]) || pair[1].contains_entirely?(pair[0])
    end.size
  end

  def overlapping_pairs : Int32
    @pairs.select do |pair|
      pair[0].any_overlap?(pair[1])
    end.size
  end
end

AOC(Int32)["superset pairs"].do do
  r1 = Range(Int32, Int32).new(2,7)
  r2 = Range(Int32, Int32).new(5,9) #[a [b a] b]
  r3 = Range(Int32, Int32).new(8,11) #[a a] [c c]
  r4 = Range(Int32, Int32).new(2,8) #[ab a] b]
  r5 = Range(Int32, Int32).new(1,7) #[b [a ab]
  r6 = Range(Int32, Int32).new(0,1) #[b b] [a a]
  r7 = Range(Int32, Int32).new(7,9) #[b [ab] a]

  assert (22..51).any_overlap?(5..57)

  assert r1.any_overlap?(r2)
  assert r2.any_overlap?(r1)

  refute r1.any_overlap?(r3)
  refute r3.any_overlap?(r1)

  assert r1.any_overlap?(r4)
  assert r4.any_overlap?(r1)

  assert r1.any_overlap?(r5)
  assert r5.any_overlap?(r1)

  refute r1.any_overlap?(r6)
  refute r6.any_overlap?(r1)

  assert r1.any_overlap?(r7)
  assert r7.any_overlap?(r1)

  assert_equal 2, CleanupPairs.new(sample).pairs_with_redundancy

  solve do
    solution CleanupPairs.new(input).pairs_with_redundancy
  end
end

AOC(Int32)["overlapping pairs"].do do
  assert_equal 4, CleanupPairs.new(sample).overlapping_pairs

  solve do
    solution CleanupPairs.new(input).overlapping_pairs
  end
end

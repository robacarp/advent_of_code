require "../helper"

sample = <<-TEXT
[1,1,3,1,1]
[1,1,5,1,1]

[[1],[2,3,4]]
[[1],4]

[9]
[[8,7,6]]

[[4,4],4,4]
[[4,4],4,4,4]

[7,7,7,7]
[7,7,7]

[]
[3]

[[[]]]
[[]]

[1,[2,[3,[4,[5,6,7]]]],8,9]
[1,[2,[3,[4,[5,6,0]]]],8,9]
TEXT

class Object
  def compare(other : Nil) : Bool?
    # puts "[?/nil] right hand ran out, left hand is #{self}"
    false
  end
end

struct Int32
  def compare(node : Node) : Bool?
    node_self = Node.new self
    # puts "[i/N] comparing #{node_self} to #{node}"
    node_self.compare node
  end

  def compare(other : self) : Bool?
    case
    when self < other
      # puts "[i/i] left hand is smaller than right hand, correct order"
      true
    when self > other
      # puts "[i/i] left hand is bigger than right hand, wrong order"
      false
    else nil
    end
  end
end

struct Nil
  def compare(other) : Bool?
    # puts "[nil/?] left hand ran out, right hand isn't. true"
    true
  end
end

class Node
  alias Subtype = self | Int32

  getter children

  def initialize
    @children = [] of Subtype
  end

  def initialize(child : Int32)
    @children = [] of Subtype
    @children << child
  end

  def <<(n : Subtype)
    @children.push n
  end

  def self.parse(input : String) : self
    stack = [] of Node
    top = nil
    chars = input.strip.chars
    accumulator = -1

    accumulate = -> (n : Int32) do
      if accumulator == -1
        accumulator = 0
      else
        accumulator *= 10
      end
      accumulator += n
    end

    dump_accumulator = -> do
      if accumulator > -1
        stack.last << accumulator
        accumulator = -1
      end
    end

    while char = chars.shift?
      case char
      when '[' then stack << Node.new
      when ']'
        dump_accumulator.call
        top = stack.pop
        stack.last << top if stack.any?
      when ','
        dump_accumulator.call
      else
        accumulate.call char.to_i
      end
    end

    if top.nil?
      raise "did not find a root node"
    end

    top
  end

  def to_s(io : IO)
    io << '['
    io << @children.map { |c| c.to_s }.join(",")
    io << ']'
  end

  def compare(int : Int32) : Bool?
    node_int = self.class.new int
    # puts "[N/i] comparing #{self} to #{node_int}"
    compare node_int
  end

  def compare(other : Node) : Bool?
    # puts "[N] comparing #{self} to #{other}"
    other.children.zip?(children).each do |(right, left)|
      # puts "[*] comparing #{left} to #{right}"
      comparison = left.compare right
      return comparison unless comparison.nil?
    end

    size.compare other.size
  end

  delegate size, to: @children
end

class Pair
  getter first, second

  def initialize(@first : Node, @second : Node)
    # compare
  end

  def compare : Bool
    # puts "[Pr] comparing #{first} to #{second}"
    first.compare(second) || false
  end
end

class DistressParser
  getter lines = [] of String

  def initialize(input : String)
    @lines = input.lines.reject(&.blank?)
  end

  def solve
    lines.each_slice(2)
      .map { |(first, second)| Pair.new Node.parse(first), Node.parse(second) }
      .map(&.compare).map_with_index do |bool, index|
        if bool
          index + 1
        else
          nil
        end
      end
  end

  def solve2
    added_lines = ["[[2]]", "[[6]]"]
    added_lines.each { |line| lines << line }

    sorted = lines.map { |str| Node.parse str }
      .sort do |a, b|
        if a.compare b ## in the right order
          -1
        else
          1
        end
      end
      .map(&.to_s)

    added_lines.map { |line| (sorted.index(line) || 0) + 1 }.product
  end
end

AOC(Int32)["Ordered Packets"].do do
  parser = DistressParser.new(sample)
  solve = parser.solve
  assert_equal 13, solve.compact.sum

  solve do
    solve = DistressParser.new(input).solve
    solution solve.compact.sum
  end
end

AOC(Int32)["Sorted Packets"].do do
  parser = DistressParser.new sample
  assert_equal 140, parser.solve2

  solve do
    parser = DistressParser.new input
    solution parser.solve2
  end
end

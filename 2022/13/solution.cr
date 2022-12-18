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

[17,7,7,7]
[17,7,7]

[]
[3]

[[[]]]
[[]]

[1,[2,[3,[4,[5,6,7]]]],8,9]
[1,[2,[3,[4,[5,6,0]]]],8,9]
TEXT

class Object
  def compare(other : Nil, ts = 0) : Bool?
    puts "#{tabs ts}[?/nil] right hand ran out, left hand is #{self}"
    false
  end

  def tabs(ts = 0)
    "   " * ts
  end
end

struct Int32
  def compare(node : Node, ts = 0) : Bool?
    node_self = Node.new self
    puts "#{tabs ts}[i/N] comparing #{node_self} to #{node}"
    node_self.compare node, ts.+(1)
  end

  def compare(other : self, ts = 0) : Bool?
    case
    when self < other
      puts "#{tabs ts}[i/i] left hand is smaller than right hand, correct order"
      true
    when self > other
      puts "#{tabs ts}[i/i] left hand is bigger than right hand, wrong order"
      false
    else nil
    end
  end
end

struct Nil
  def compare(other : self, ts = 0) : Bool?
    {% raise "did this happen?" %}
    # puts "#{tabs ts}[nil/?] left hand ran out, right hand is #{other}"
    # false
  end

  def compare(other, ts = 0) : Bool?
    puts "#{tabs ts}[nil/?] left hand ran out, right hand isn't. true"
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

  # If both values are integers, the lower integer should come first.
  # - If the left integer is lower than the right integer, the inputs are in the right order.
  # - If the left integer is higher than the right integer, the inputs are not in the right order.
  # - Otherwise, the inputs are the same integer; continue checking the next part of the input.
  #
  # If both values are lists, compare the first value of each list, then the second value, and so on.
  # - If the left list runs out of items first, the inputs are in the right order.
  # - If the right list runs out of items first, the inputs are not in the right order. 
  # - If the lists are the same length and no comparison makes a decision about the order, continue checking the next part of the input.
  #
  # If exactly one value is an integer, convert the integer to a list which contains that integer as its only value, then retry the comparison. 
  # For example, if comparing [0,0,0] and 2, convert the right value to [2] (a list containing 2); the result is then found by instead comparing [0,0,0] and [2].
  def compare(int : Int32, ts = 0) : Bool?
    node_int = self.class.new int
    puts "#{tabs ts}[N/i] comparing #{self} to #{node_int}"
    compare node_int, ts + 1
  end

  def compare(other : Node, ts = 0) : Bool?
    # puts "#{tabs ts}[N] comparing #{self} to #{other}"

    # ts += 1

    # todo properly zip with nils
    other.children.zip?(children).each do |(right, left)|
      puts "#{tabs ts}[*] comparing #{left} to #{right}"
      comparison = left.compare(right, ts + 1)
      return comparison unless comparison.nil?
    end

    if size < other.size
      puts "#{tabs ts}[N/N] left hand ran out, right order. true"
      true
    end

    if size > other.size
      puts "#{tabs ts}[N/N] right hand ran out, wrong order. false"
      false
    end
  end

  delegate size, to: @children
end

class Pair
  getter first, second

  def initialize(@first : Node, @second : Node)
    # compare
  end

  def compare : Bool
    puts "[Pr] comparing #{first} to #{second}"
    bacon = first.compare(second, 1) || false
    # puts "#{first}\t#{second} => #{bacon}"
    bacon
  end
end

class DistressParser
  def initialize(input : String)
    @pairs = Array(Pair).new

    input.lines.reject {|l| l.blank? }.each_slice(2) do |(a, b)|
      # puts a, b
      @pairs << Pair.new Node.parse(a), Node.parse(b)
    end
  end

  def solve
    @pairs.map(&.compare).map_with_index do |bool, index|
      if bool
        index + 1
      else
        nil
      end
    end
  end
end

AOC(Int32)["Ordered Packets"].do do
  parser = DistressParser.new(sample)
  solve = parser.solve
  pp solve
  assert_equal 13, solve.compact.sum

  solve do
    solve = DistressParser.new(input).solve
    solution solve.compact.sum
  end
end

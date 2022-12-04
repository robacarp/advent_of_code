require "../kit"

class Node
  alias Subtype = self | Int32

  property left : Subtype?
  property right : Subtype?
  property parent : self?

  def initialize(); end
  def initialize(@left, @right); end

  def to_s(io : IO)
    io << '['
    io << left
    io << ','
    io << right
    io << ']'
  end

  def inspect(io : IO)
    to_s(io)
  end

  def right! : Subtype
    right.not_nil!
  end

  def left! : Subtype
    left.not_nil!
  end

  def traverse(&block : self -> _)
    left_, right_ = left, right

    if left_.is_a? self
      left_.traverse &block
    else
      block.call self
    end

    if right_.is_a? self
      right_.traverse &block
    end
  end

  def reduce
    while explode || split
      puts "\t#{self}"
      break
    end
    puts "reduced\t#{self}"
  end

  def explode : Bool
    _, _, _, went = explode 0
    went
  end

  def explode(depth : Int32)
    i = ->() { print "\t" * depth }
    i.call
    print "xplod\t#{self} at #{depth}"
    # returns: replace "me" with this, propigate-left, propigate-right, changed
    if depth >= 4
      puts " explodin!"
      return {0, left.as(Int32), right.as(Int32), true}
    end
    puts

    left_, right_ = left, right
    depth += 1
    changed = false

    if left_.is_a? self
      @left, left_bubble, right_sinker, changed = left_.explode depth
      i.call
      puts "subsplode: #{@left} #{left_bubble} #{right_sinker} #{changed}"
      @right = sink_add_left right!, right_sinker.as(Int32) if right_sinker
      i.call
      puts "sinkeradd: #{@right}"
    end

    if !changed && right_.is_a? self
      @right, left_sinker, right_bubble, changed = right_.explode depth
      i.call
      puts "subsplode: #{@right} #{left_sinker} #{right_bubble} #{changed}"
      @left = sink_add_right left!, left_sinker.as(Int32) if left_sinker
      i.call
      puts "sinkeradd: #{@left}"
    end

    i.call
    puts "finsplode: #{self} #{left_bubble} #{right_bubble} #{changed}"

    { self, left_bubble, right_bubble, changed }
  end

  def sink_add_right(node : Int32, value)
    node + value
  end

  def sink_add_right(node : self, value)
    node_right = node.right!
    if node_right.is_a? Int32
      node.right = node_right + value
      puts "adding #{node_right} to #{value}"
      node
    else
      sink_add_right node_right, value
    end
  end

  def sink_add_left(node : Int32, value)
    node + value
  end

  def sink_add_left(node : self, value)
    node_left = node.left!
    if node_left.is_a? Int32
      node.left = node_left + value
      puts "adding #{node_left} to #{value}"
      node
    else
      sink_add_left node_left, value
    end
  end

  def split
    node_left = left
    node_right = right
    did_split = false

    if node_left.is_a? self
      did_split ||= node_left.split
    elsif node_left.is_a? Int32
      if node_left >= 10
        puts "split\t#{node_left}"
        @left = self.class.new(node_left // 2, node_left./(2).ceil.to_i)
        did_split = true
      end
    end

    if node_right.is_a? self
      did_split ||= node_right.split
    elsif node_right.is_a? Int32
      if node_right >= 10
        puts "split\t#{node_right}"
        @right = self.class.new(node_right // 2, node_right./(2).ceil.to_i)
        did_split = true
      end
    end

    did_split
  end

  def dup
    self.class.new left.dup, right.dup
  end

  def +(other : self)
    self.class.new(self.dup, other.dup).tap do |new|
      self.parent = new
      other.parent = new
      puts "adding\t#{other}\n got\t#{new}"
      new.reduce
    end
  end

  def magnitude : Int32
    left_, right_ = left, right
    sum = 0

    if left_.is_a? self
      sum += 3 * left_.magnitude
    elsif left_.is_a? Int32
      sum += 3 * left_
    end

    if right_.is_a? self
      sum += 2 * right_.magnitude
    elsif right_.is_a? Int32
      sum += 2 * right_
    end

    sum
  end

  def self.parse(number : String) : self
    stack = [] of Node
    chars = number.chars
    accumulator = 0
    stage = nil

    while char = chars.shift?

      case char
      when '['
        stack.push Node.new

      when ']'
        if stage
          stack[-1].right = stage
          stage.parent = stack[-1]
          stage = nil
        else
          stack[-1].right = accumulator
          accumulator = 0
        end

        stage = stack.pop
      when ','
        if stage
          stack[-1].left = stage
          stage.parent = stack[-1]
          stage = nil
        else
          stack[-1].left = accumulator
          accumulator = 0
        end

      else
        accumulator *= 10
        accumulator += char.to_i
      end
    end

    if stage
      stage
    else
      raise "could not parse: #{number} #{stage} #{accumulator}"
    end
  end
end

# To add two snailfish numbers, form a pair from the left and right parameters of the addition operator. For example, [1,2] + [[3,4],5] becomes [[1,2],[[3,4],5]].
#
#
# To reduce a snailfish number, you must repeatedly do the first action in this list that applies to the snailfish number:
# 
#     If any pair is nested inside four pairs, the leftmost such pair explodes.
#     If any regular number is 10 or greater, the leftmost such regular number splits.


puzzle "Snailfish" do
  # test "" do
  #   <<-INPUT
  #     [1,2]
  #     [[1,2],3]
  #     [9,[8,7]]
  #     [[1,9],[8,5]]
  #     [[[[1,2],[3,4]],[[5,6],[7,8]]],9]
  #     [[[9,[3,8]],[[0,9],6]],[[[3,7],[4,9]],3]]
  #     [[[[1,3],[5,3]],[[1,3],[8,7]]],[[[4,9],[6,9]],[[8,2],[7,3]]]]
  #   INPUT
  # end

  # magnitude tests
  # test "29" { "[9,1]" }
  # test "21" { "[1,9]" }
  # test "143" { "[[1,2],[[3,4],5]]" }
  # test "129" { "[[9,1],[1,9]]"  }
  # test "1384" { "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]" }
  # test "445" { "[[[[1,1],[2,2]],[3,3]],[4,4]]" }
  # test "791" { "[[[[3,0],[5,3]],[4,4]],[5,5]]" }
  # test "1137" { "[[[[5,0],[7,4]],[5,5]],[6,6]]" }
  # test "3488" { "[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]" }

  # test "4140" do
  # test "[[[[6,6],[7,6]],[[7,7],[7,0]]],[[[7,7],[7,7]],[[7,8],[9,9]]]]" do
  #   <<-FISH
  #     [[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
  #     [[[5,[2,8]],4],[5,[[9,9],0]]]
  #     [6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
  #     [[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
  #     [[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
  #     [[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
  #     [[[[5,4],[7,7]],8],[[8,3],8]]
  #     [[9,3],[[9,9],[6,[4,9]]]]
  #     [[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
  #     [[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]
  #   FISH
  # end

  # explode tests
  # test "[[[[0,9],2],3],4]" { "[[[[[9,8],1],2],3],4]" }
  # test "[7,[6,[5,[7,0]]]]" { "[7,[6,[5,[4,[3,2]]]]]" }  #  (the 2 has no regular number to its right, and so it is not added to any regular number).
  # test "[[6,[5,[7,0]]],3]" { "[[6,[5,[4,[3,2]]]],1]" }
  # test "[[3,[2,[8,0]]],[9,[5,[7,0]]]]" { "[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]" }

  # split tests
  # test "[0,[6,7]]" { "[0,13]" }
  # test "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]" { "[[[[4,3],4],4],[7,[[8,4],9]]]\n[1,1]" }

  test "[[[[14,0],[7,7]],[[6,0],[6,7]]],[[[0,[10,8]],[0,[7,5]]],[[3,[2,5]],[7,7]]]]" do
    "[[[[14,0],[7,7]],[[6,0],[6,5]]],[[[[2,4],[6,8]],[0,[7,5]]],[[3,[2,5]],[7,7]]]]"
  end

  input do
    File.read("input.txt")
  end

  solve do |input|
    node = input.split('\n')
      .reject(&.blank?)
      .map(&.strip)
      .map {|snail| Node.parse snail }
      .reduce {|sum, node| sum ? sum + node : node }

    puts node
    node.reduce
    node#.magnitude
  end
end



#   aaaaa
#  b     c
#  b     c
#   ddddd
#  e     f
#  e     f
#   ggggg


data = File.read_lines("input.txt")
data = File.read_lines("testing.txt")

digit_counts = Hash(Int32, Int32).new { 0 }

data.each do |line|
  sequence_data, output_value = line.split(" | ")
  values = output_value.split ' '

  values.each do |value|
    digit_counts[value.size] += 1
  end
end

puts "number of 1/4/7/8s: #{digit_counts.select{ |k,v| [2,4,3,7].includes? k }.values.sum}"

puts "-" * 80

class Decoder
  @segments : Hash(Char, Array(Char))
  @found_1 = false
  @found_7 = false
  @found_4 = false

  ALL_CHARS = ['a','b','c','d','e','f','g']

  def initialize
    @segments = {
      'a' => ALL_CHARS.dup,
      'b' => ALL_CHARS.dup,
      'c' => ALL_CHARS.dup,
      'd' => ALL_CHARS.dup,
      'e' => ALL_CHARS.dup,
      'f' => ALL_CHARS.dup,
      'g' => ALL_CHARS.dup,
    }
  end

  def slurp(sequence)
    case sequence.size
    when 2 # number 1
      @found_1 = true
      ensure_only sequence, at: ['c', 'f']
      remove sequence, at: ['a', 'b', 'd', 'e', 'g']
    when 3 # number 7
      @found_7 = true
      ensure_only sequence, at: ['a', 'c', 'f']
      remove sequence, at: ['b', 'd', 'e', 'g']
    when 4 # number 4
      @found_4 = true
      remove sequence, at: ['a', 'e', 'g']
      ensure_only sequence, at: ['b', 'c', 'd', 'f']

    when 5 # number 2/3/5
      raise "cannot decode 2/3/5 until 1 and 4 have been decoded" unless @found_1 && @found_4
      one_components = (@segments['c'] + @segments['f']).uniq

      if (one_components - sequence).none?
        # 3, both components of a "1" must be present
        remove sequence, at: ['b','e']

      elsif detect sequence, at: 'b'
        # 5, the left fork of a "4" must be present
        remove sequence, at: ['c', 'e']
      else
        # 2
        remove sequence, at: ['b', 'f']
      end

    when 6 # number 6/9/0
    when 7 # number 8
    end
      pp self
  end

  def remove(sequence, at positions : Array(Char))
    positions.each { |position| remove sequence, at: position }
  end

  def remove(sequence, at position : Char)
    if @segments[position].size == 1 && (@segments[position] - sequence).none?
      # puts "Cannot remove #{sequence} at #{position}, it would be empty(#{@segments[position]})"
      return
    end

    @segments[position] -= sequence

    if @segments[position].size == 1
      @segments.each do |k, v|
        next if k == position
        @segments[k] -= @segments[position]
      end
    end
  end

  def ensure_only(sequence, at positions : Array(Char))
    positions.each { |position| ensure_only sequence, at: position }
  end

  def ensure_only(sequence, at position : Char)
    @segments[position] = sequence & @segments[position]
  end

  def detect(sequence, at positions : Array(Char))
    positions.each { |position| detect sequence, at: position }
  end

  def detect(sequence, at position : Char)
    (sequence & @segments[position]).any?
  end

  def decode(sequence) : Int32
    case sequence.size
    when 2 then 1
    when 3 then 7
    when 4 then 4
    when 7 then 8

    when 5 # number 2/3/5
      position_b = detect(sequence, at: 'b')
      position_e = detect(sequence, at: 'e')

      case
      when ! position_b && ! position_e then 3
      when   position_b && ! position_e then 5
      when ! position_b &&   position_e then 2
      else -1
      end

    when 6 # number 6/9/0
      position_d = detect sequence, at: 'd'
      position_e = detect sequence, at: 'e'

      case
      when ! position_d then 0
      when ! position_e then 6
      else 9
      end

    else
      raise "unable to decode #{sequence}"
    end
  end

  def clear
    @segments.clear
    @segments['a'] = ALL_CHARS.dup
    @segments['b'] = ALL_CHARS.dup
    @segments['c'] = ALL_CHARS.dup
    @segments['d'] = ALL_CHARS.dup
    @segments['e'] = ALL_CHARS.dup
    @segments['f'] = ALL_CHARS.dup
    @segments['g'] = ALL_CHARS.dup
  end
end

decoder = Decoder.new
sum = data.each do |line|
  decoder.clear
  sequence_data, output_value = line.split(" | ")

  sequence_data.split(' ').sort_by(&.size).each do |sequence|
    puts "slurping #{sequence}"
    decoder.slurp sequence.chars
    # break if [2,3,4].includes? sequence.size
  end

  # have 1955
  # want 1625
  puts "="*20

  result = 0
  output_value.split(' ').each do |value|
    print value
    decoded = decoder.decode value.chars
    puts " decoded to #{decoded}"
    result *= 10
    result += decoded
  end
  puts "#{output_value} => #{result}"
  pp decoder
  break
end # .sum

pp sum

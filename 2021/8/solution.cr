#   aaaa0
#  b     c
#  1     2
#   dddd3
#  e     f
#  4     5
#   gggg6


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

possibilities = %|abcdefg|.split("").permutations
puts "#{possibilities.size} possible combinations"


data.each do |line|
  sequence_data, output_value = line.split(" | ")
  sequences = sequence_data.split(' ').sort_by(&.size).map(&.split("")).map(&.sort)

  valid_permutations = possibilities.select do |possibility|
    messages = [] of String
    messages << "possibility: #{possibility}"

    match = sequences.all? do |sequence|
      messages << "sequence: #{sequence} (#{sequence.size})"
      case sequence.size
      when 2 # number = 1
        messages << "1 #{sequence} == #{[possibility[2], possibility[5]].sort}"
        sequence == [possibility[2], possibility[5]].sort
      when 3 # number = 7
        messages << "7 #{sequence} == #{[possibility[0], possibility[2], possibility[5]].sort}"
        sequence == [possibility[0], possibility[2], possibility[5]].sort
      when 4 # number = 4
        messages << "4 #{sequence} == #{[possibility[1], possibility[2], possibility[3], possibility[5]].sort}"
        sequence == [possibility[1], possibility[2], possibility[3], possibility[5]].sort
      when 5 # number = 2/3/5
        messages << "2/3/5 #{sequence} ⊃? #{[possibility[0], possibility[3], possibility[6]]}"
        # messages.each {|m| puts m}

        ([possibility[0], possibility[3], possibility[6]] - sequence).none?
      when 6 # number = 6/9/0
        true
      when 7 # number = 8
        true
      end
    end
  end

  puts "found #{valid_permutations.size} possible combinations:"
  puts valid_permutations

  valid_permutations.last(1).each do |permutation|
    decoded = output_value.split(' ').map(&.split("")).reduce(0) do |result, value|
      decoded_value = case value.size
      when 2 then 1
      when 3 then 7
      when 4 then 4
      when 7 then 8

      when 5 # number 2/3/5
        case
        when ! value.includes?(permutation[1]) && ! value.includes?(permutation[4]) then 3
        when   value.includes?(permutation[1]) && ! value.includes?(permutation[4]) then 2
        when ! value.includes?(permutation[1]) &&   value.includes?(permutation[4]) then 5
        else
          0
        end

      when 6 # number 6/9/0
        case
        when ! value.includes?(permutation[3]) then 0
        when ! value.includes?(permutation[2]) then 6
        else 9
        end

      else
        raise "unable to decode #{value}"
      end

      # puts "#{value} => #{decoded_value}"

      result *= 10
      result + decoded_value
    end

    puts "#{output_value} => #{decoded}"
  end
end

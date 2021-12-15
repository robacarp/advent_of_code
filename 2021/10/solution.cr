require "big"

programs = File.read_lines("testing.txt")
programs = File.read_lines("input.txt")

stack = [] of Char
error_score = 0

autocomplete_scores = programs.map do |program|
  stack.clear

  program.each_char do |operation|
    # print "#{operation} "
    case
    when ['[', '(', '<', '{'].includes? operation
      stack.push operation
    when operation == ']' && stack.last == '['
      stack.pop
    when operation == ')' && stack.last == '('
      stack.pop
    when operation == '}' && stack.last == '{'
      stack.pop
    when operation == '>' && stack.last == '<'
      stack.pop
    else
      puts "corrupt program. #{operation} mismatch with #{stack.last}"

      case operation
      when ')' then error_score += 3
      when ']' then error_score += 57
      when '}' then error_score += 1197
      when '>' then error_score += 25137
      end

      stack.clear
      break
    end
  end

  if stack.any?
    puts "incomplete program line"

    stack.reverse.reduce(0.to_big_i) do |score, operation|
      score *= 5
      score += case operation
      when '(' then 1
      when '[' then 2
      when '{' then 3
      when '<' then 4
      else raise "corrupt stack, can't autocomplete: #{operation}"
      end
    end
  else
    nil
  end
end


puts "error score for file: #{error_score}"
scores = autocomplete_scores.compact.sort
puts "autocomplete scores for file: #{scores}"
puts "middle score: #{scores[(scores.size / 2).to_i]}"

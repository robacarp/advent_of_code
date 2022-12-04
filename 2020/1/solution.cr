lines = File.read_lines("input.txt")

numbers = lines.map(&.to_i)

numbers.each do |n|
  numbers.each do |m|
    if n + m == 2020
      puts "#{n} + #{m} = 2020"
      puts "#{n} * #{m} = #{n * m}"
      break 2
    end
  end
end

numbers.each do |n|
  numbers.each do |m|
    numbers.each do |o|
      if n + m + o == 2020
        puts "#{n} + #{m} + #{o} = 2020"
        puts "#{n} * #{m} * #{o}= #{n * m * o}"
        exit
      end
    end
  end
end

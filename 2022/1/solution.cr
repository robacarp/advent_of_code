sample = <<-EEE
1000
2000
3000

4000

5000
6000

7000
8000
9000

10000
EEE

class CalorieCounter

  getter calorie_counts = [0]

  def run(data)
    data.split('\n').each do |meal|
      if meal.blank?
        calorie_counts.push 0
        next
      end
      calorie_counts[-1] += meal.to_i
    end
  end

  def biggest_stash
    calorie_counts.max
  end

  def three_biggest_stashes
    calorie_counts.sort.last(3).sum
  end
end

cc = CalorieCounter.new
cc.run sample
puts "sample data:"
bs = cc.biggest_stash
ok = bs == 24000 ? "OK" : "NOTOK"
puts "\tbiggest stash: #{bs} (#{ok})"

tbs = cc.three_biggest_stashes
ok = tbs == 45000 ? "OK" : "NOTOK"
puts "\tthree biggest stashes: #{tbs} (#{ok})"

cc = CalorieCounter.new
cc.run File.read("input.txt")
puts "input data:"
bs = cc.biggest_stash
puts "\tbiggest stash: #{bs}"
tbs = cc.three_biggest_stashes
puts "\tthree biggest stashes: #{tbs}"

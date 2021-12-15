class BitCounter
  getter ones = 0
  getter zeros = 0

  def increment(value)
    case value
    when '1' then @ones += 1
    when '0' then @zeros += 1
    end
  end

  def dominant
    if ones >= zeros
      1
    else
      0
    end
  end

  def secondary
    if ones >= zeros
      0
    else
      1
    end
  end

  def reset
    @ones = 0
    @zeros = 0
  end
end

class PowerConverter
  getter counters : Array(BitCounter)

  def initialize(size)
    @counters = Array(BitCounter).new(size) { BitCounter.new }
  end

  def ingest(word : String)
    word.each_char.with_index do |bit, index|
      counters[index].increment bit
    end
  end

  def gamma
    counters.reduce(0) do |g, i|
      (g << 1) + i.dominant
    end
  end

  def epsilon
    counters.reduce(0) do |e, i|
      (e << 1) + i.secondary
    end
  end
end


file = "input.txt"
lines = File.read_lines(file)

pc = PowerConverter.new(lines.first.size)

lines.each do |line|
  pc.ingest line
end

gamma = pc.gamma
epsilon = pc.epsilon

puts "gamma: #{gamma} epsilon: #{epsilon} product: #{gamma * epsilon}"
puts "-"*80

class OxygenGenerator
  getter counters : Array(BitCounter)
  getter lines : Array(String)

  def initialize(size)
    @counters = Array(BitCounter).new(size) { BitCounter.new }
    @lines = [] of String
  end

  def ingest(word : String)
    lines << word
  end

  def recalculate
    counters.each &.reset
    lines.each do |line|
      line.each_char.with_index do |bit, index|
        counters[index].increment bit
      end
    end
  end

  def rating!
    counters.each.with_index do |counter, index|
      dominant = counter.dominant
      lines.select! do |line|
        line[index].to_i == dominant
      end

      break if lines.size <= 1

      recalculate
    end

    lines.first.to_i(2)
  end
end

class CO2Scrubber
  getter counters : Array(BitCounter)
  getter lines : Array(String)

  def initialize(size)
    @counters = Array(BitCounter).new(size) { BitCounter.new }
    @lines = [] of String
  end

  def ingest(word : String)
    lines << word
  end

  def recalculate
    counters.each &.reset
    lines.each do |line|
      line.each_char.with_index do |bit, index|
        counters[index].increment bit
      end
    end
  end

  def rating!
    counters.each.with_index do |counter, index|
      secondary = counter.secondary
      lines.select! do |line|
        line[index].to_i == secondary
      end

      break if lines.size <= 1

      recalculate
    end

    lines.first.to_i(2)
  end
end

og = OxygenGenerator.new(lines.first.size)
co = CO2Scrubber.new(lines.first.size)
lines.each do |line|
  og.ingest line
  co.ingest line
end

og.recalculate
co.recalculate

oxygen_rating = og.rating!
co2_rating = co.rating!
puts "Oxygen Generator Rating: #{oxygen_rating}"
puts "CO2 Scrubber Rating: #{co2_rating}"

puts "Life Support Rating: #{oxygen_rating * co2_rating}"

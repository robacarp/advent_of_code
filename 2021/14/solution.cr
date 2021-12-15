require "colorize"
require "big"

TESTING = false

data = if TESTING
  File.read_lines("testing.txt")
else
  File.read_lines("input.txt")
end

def yolo(*args)
  if TESTING
    puts *args
  end
end

def pretty(hash)
  str = String.build do |s|
    s << '{'
    has_key = false
    hash.keys.sort.each do |k|
      if hash[k] > 0
        s << ' ' if has_key
        has_key = true
        s << '"'
        s << k
        s << "\"="
        s << hash[k]
      end
    end
    s << '}'
  end

  puts str
end

base_polymer = data.shift

chain = data
  .compact
  .reject(&.blank?)
  .reduce(Hash(String,String).new) do |store, line|
    key, value = line.split(" -> ")
    store[key] = value
    store
  end

polymer = Hash(String,BigInt).new { 0.to_big_i }
base_polymer
  .split("")
  .each_cons(2) { |letters| polymer[letters.join("")] += 1 }

40.times do |i|
  yolo "#{i} - polymer length: #{polymer.size}"

  time = Time.measure do
    polymer.clone.each do |pair, count|
      yolo "pair: #{pair} (#{count})"
      # new_polymer += letters.first

      if insertion = chain[pair]?
        yolo "inserting #{insertion}"
        polymer[pair] -= count# += insertion
        first, last = pair.split ""
        polymer[first+insertion] += count
        polymer[insertion+last] += count
      end

      pretty polymer
    end
  end

  puts " - took #{time.hours}:#{time.minutes}:#{time.seconds}.#{time.milliseconds}"
end

counts = Hash(String,BigInt).new { 0.to_big_i }
polymer.each do |k, v|
  k.split("").each do |k_|
    counts[k_] += v
  end
end
counts.transform_values!(&.//(2))

counts[base_polymer[0].to_s] += 1
counts[base_polymer[-1].to_s] += 1

counts = counts.invert
max_count, max_letter = counts.max
min_count, min_letter = counts.min

puts "most common #{max_letter}@#{max_count}"
puts "least common #{min_letter}@#{min_count}"
puts "most count - least count = #{max_count - min_count}"

require "benchmark"

puts "building haystack"

haystack = (0..1_000_000).to_a
needle = haystack[500_000]
haystack.shuffle!

haystack_set = haystack.to_set

puts "searching for needle"

Benchmark.ips do |x|
  x.report("array#includes?") { haystack.includes? needle }
  x.report("set#includes?") { haystack_set.includes? needle }
end

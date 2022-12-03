require "colorize"

class AOC
  getter title

  def self.[](title)
    new title
  end

  def initialize(@title : String)
  end

  def do
    with self yield
  end

  def assert_equal(expected, actual)
    ok = expected == actual ? "OK".colorize.green : "NOTOK".colorize.red
    message = "#{title}: #{actual} (#{ok})"
    raise message unless expected == actual
    puts message
  end

  def display_solution(value)
    puts "#{title.colorize.bold}: #{value}"
  end
end

def input
  File.read "input.txt"
end

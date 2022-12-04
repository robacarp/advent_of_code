require "colorize"

class AOC(SolutionType)
  getter title
  getter took : Time::Span?
  getter solution : SolutionType?

  def self.[](title)
    new title
  end

  def initialize(@title : String)
    @had_tests = false
  end

  def do
    with self yield
  end

  def solve
    @took = Time.measure do
      yield
    end

    if s = @solution
      display_solution s
    end
  end

  def solution(s)
    @solution = s
  end

  def refute(condition : Bool)
    assert ! condition
  end

  def assert(condition : Bool)
    ok = "NOTOK".colorize.red
    raise "#{ok} failed condition" unless condition
    @had_tests = true
    print ".".colorize.green
  end

  private def newline_if_tests
    if @had_tests
      @had_tests = false
      "\n"
    else
      ""
    end
  end

  def assert_equal(expected, actual)
    ok = expected == actual ? "OK".colorize.green : "NOTOK".colorize.red
    raise "expected #{expected} but got #{actual}" unless expected == actual
    puts "#{newline_if_tests}#{title}: #{actual} (#{ok})"
  end

  def display_solution(value)
    puts "#{newline_if_tests}#{title.colorize.bold}: #{value}"
    if took = @took
      seconds = took.total_seconds

      formatted_duration = if seconds > 0.1
        "#{(seconds).*(100).trunc./(100)}s".colorize.red
      elsif seconds > 0.001
        "#{(seconds * 1_000).trunc}ms".colorize.yellow
      elsif seconds > 0.000_001
        "#{(seconds * 100_000).trunc}µs".colorize.green
      elsif seconds > 0.000_000_001
        "#{(seconds * 1_000_000_000).trunc}ns".colorize.green
      else
        "no discernible time at all".colorize.green
      end

      puts "took #{formatted_duration}"
    end
  end
end

def input
  File.read "input.txt"
end

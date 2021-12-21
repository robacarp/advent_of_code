require "big"
require "colorize"

class Puzzle
  PUZZLE_CLASSES = [] of self.class

  macro inherited
    PUZZLE_CLASSES << {{ @type.id }}
  end

  def self.test_input()
    raise "no input provided"
  end

  def self.solution(input : String)
    raise "no solution implemented"
  end

  def self.test_output(value)
    puts "Tests passed. Solution result: #{value}"
  end

  def self.run_all_puzzles
    first = true
    PUZZLE_CLASSES.each do |putzle|
      puts "="*80 unless first
      first = false

      if putzle.run_tests
        response = putzle.solution putzle.test_input
        putzle.test_output response
      end
    end
  end

  def self.run_tests : Bool
    true
  end

  def self.xputs(*args)
    print " #  ".colorize.bold
    puts *args
  end

  delegate xputs, to: self.class
end

at_exit do
  Puzzle.run_all_puzzles
rescue e
  puts
  puts e.message
  e.backtrace.each do |frame|
    puts frame
  end
end

macro puzzle(name)
  class {{ name.id }} < Puzzle
    TESTS = {} of String => String

    def self.run_tests : Bool
      all_passed = true
      xputs "Running tests from #{self.name}:"

      TESTS.each do |expected, input|
        xputs "\ttesting #{input[0..12]}: "
        actual = ""

        duration = Time.measure do
          actual = solution(input).to_s
        end

        if expected == actual
          xputs "pass! ".colorize.green
          xputs "took #{duration}"
          all_passed &= true
        else
          xputs "fail!".colorize.red
          xputs "#{input} should have generated #{expected} but #{actual} was generated instead"
          xputs "took #{duration}"
          all_passed = false
        end
      end

      all_passed
    end

    macro solve
      def self.solution(input : String)
        \{{ yield }}
      end
    end

    macro test(expected_result)
      input = begin
        \{{ yield }}
      end

      TESTS[\{{ expected_result }}] = input
    end

    macro input
      def self.test_input() : String
        \{{ yield }}
      end
    end

    macro output
      def self.test_output(value)
        str = \{{ yield }}
        puts str
      end
    end

    {{ yield }}
  end
end

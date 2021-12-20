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
end

at_exit do
  Puzzle.run_all_puzzles
end

macro puzzle(name)
  class {{ name.id }} < Puzzle
    TESTS = {} of String => String

    def self.run_tests : Bool
      all_passed = true
      puts "Running tests from #{self.name}:"

      TESTS.each do |expected, input|
        print "\ttesting #{input[0..12]}: "
        actual = solution(input).to_s

        if expected == actual
          puts "pass!".colorize.green
          all_passed &= true
        else
          puts "fail!".colorize.red
          puts "#{input} should have generated #{expected} but #{actual} was generated instead"
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

require "../helper"
require "log"

sample = <<-TEXT
Monkey 0:
  Starting items: 79, 98
  Operation: new = old * 19
  Test: divisible by 23
    If true: throw to monkey 2
    If false: throw to monkey 3

Monkey 1:
  Starting items: 54, 65, 75, 74
  Operation: new = old + 6
  Test: divisible by 19
    If true: throw to monkey 2
    If false: throw to monkey 0

Monkey 2:
  Starting items: 79, 60, 97
  Operation: new = old * old
  Test: divisible by 13
    If true: throw to monkey 1
    If false: throw to monkey 3

Monkey 3:
  Starting items: 74
  Operation: new = old + 3
  Test: divisible by 17
    If true: throw to monkey 0
    If false: throw to monkey 1
TEXT

class Monkey
  Log = ::Log.for(self)

  alias Worry = Int64

  CAST_WORRY = ->(worry : String) { worry.to_i }

  getter worry_levels : Array(Worry) = [] of Worry
  getter identifier : String
  getter inspections : Int64 = 0

  @operation : Proc(Worry, Worry) = ->(old : Worry) { old }
  @test : Proc(Worry, Bool) = ->(worry_level : Worry) { false }
  property relaxor : Proc(Worry, Worry) = ->(worry_level : Worry) { worry_level }

  getter true_throw : Int32 = -1
  getter false_throw : Int32 = -1

  property true_monkey : Monkey { NullMonkey.new }
  property false_monkey : Monkey { NullMonkey.new }

  def initialize(stanza : String, @identifier : String, @relaxor)
    stanza.lines.skip(1).each do |line|
      label, data = line.split(": ")
      case label
      when /Starting items/
        data.split(", ", remove_empty: true).each do |worry_level|
          @worry_levels << CAST_WORRY.call worry_level
        end
      when /Operation/
        math = data.split(" = ")[1]
        sort_out_operation math
      when /Test/
        sort_out_test data
      when /If true/
        data =~ /throw to monkey (\d+)/
        monkey_no = $1
        @true_throw = monkey_no.not_nil!.to_i
      when /If false/
        data =~ /throw to monkey (\d+)/
        monkey_no = $1
        @false_throw = monkey_no.not_nil!.to_i
      end
    end
  end

  def sort_out_operation(math : String)
    if math =~ /old \+ (\d+)/
      n = $1.to_i
      @operation = -> (old : Worry) { old + n }
    elsif math =~ /old \* (\d+)/
      n = $1.to_i
      @operation = -> (old : Worry) { old * n }
    elsif math =~ /old \* old/
      @operation = -> (old : Worry) { old * old }
    else
      raise "Unknown operation: #{math}"
    end
  end

  def sort_out_test(data : String)
    case data
    when /divisible by (\d+)/
      n = $1.to_i
      @test = -> (worry_level : Worry) { worry_level % n == 0 }
    when /even/
      @test = -> (worry_level : Worry) { worry_level.even?  }
    when /odd/
      @test = -> (worry_level : Worry) { worry_level.odd?  }
    else
      raise "Unknown test: #{data}"
    end
  end

  def play
    while @worry_levels.any?
      @inspections += 1
      worry = @worry_levels.shift
      worry = @operation.call worry
      worry = @relaxor.call worry

      if @test.call worry
        true_monkey.worry_levels << worry
      else
        false_monkey.worry_levels << worry
      end
    end
  end
end

class NullMonkey < Monkey
  def initialize
    @identifier = "nullmonkey"
  end
end

class MonkeyGame
  getter monkeys = [] of Monkey

  def initialize(input, relaxor)
    stanza = [] of String
    input.lines.each.slice(7).each.with_index do |stanza, i|
      @monkeys << Monkey.new stanza.join("\n"), i.to_s, relaxor
    end

    @monkeys.each do |monkey|
      monkey.true_monkey = @monkeys[monkey.true_throw]
      monkey.false_monkey = @monkeys[monkey.false_throw]
    end
  end

  def play
    @monkeys.each &.play
  end
end

Log.setup(:warn,
  Log::IOBackend.new(
    dispatcher: Log::DispatchMode::Sync,
    formatter: Log::Formatter.new { |log_entry, io|
      io << "#{log_entry.severity} #{log_entry.source} #{log_entry.message}"
    }
  )
)

AOC(Int64)["monkey inspections"].do do
  relaxor = ->(worry_level : Monkey::Worry) { worry_level // 3 }

  game = MonkeyGame.new sample, relaxor

  20.times { game.play }
  assert_equal 10605, game.monkeys.map(&.inspections).sort.last(2).product

  solve do
    game = MonkeyGame.new input, relaxor

    20.times { game.play }
    solution game.monkeys.map(&.inspections).sort.last(2).product
  end
end

AOC(Int64)["more monkey inspections"].do do
  # 23 * 19 * 13 * 17 = 96577
  relaxor = ->(worry_level : Monkey::Worry) { worry_level % 96577 }
  count = 10_000

  game = MonkeyGame.new(sample, relaxor)
  count.times { game.play }
  assert_equal 2713310158, game.monkeys.map(&.inspections).sort.last(2).product

  solve do
    # 3 * 5 * 2 * 13 * 11 * 17 * 19 * 7 = 9699690
    relaxor = ->(worry_level : Monkey::Worry) { worry_level % 9699690 }

    game = MonkeyGame.new(input, relaxor)
    count.times { game.play }
    solution game.monkeys.map(&.inspections).sort.last(2).product
  end
end

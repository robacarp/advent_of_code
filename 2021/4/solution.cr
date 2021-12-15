require "colorize"

class Board
  @cells : Array(Array(Cell))
  @last_marked_call = 0

  def initialize(@cells)
  end

  def mark(number : Int32) : Bool
    each_cell do |cell|
      if cell == number
        cell.mark!
        @last_marked_call = number
        return true
      end
    end

    false
  end

  def reset!
    each_cell do |cell|
      cell.mark! false
    end
  end

  def score
    unmarked_cells.map(&.number).sum * @last_marked_call
  end

  def won?
    won_any_rows? || won_any_cols?
  end

  def unmarked_cells
    cells = [] of Cell
    each_cell do |cell|
      cells << cell unless cell.marked?
    end

    cells
  end

  private def won_any_rows?
    @cells.each.with_index do |row, i|
      return true if row.all? &.marked?
    end
  end

  private def won_any_cols?
    @cells.first.each.with_index do |_, col_no|
      column = @cells.map do |row|
        row[col_no]
      end

      return true if column.all? &.marked?
    end
  end

  def each_cell
    @cells.each.with_index do |row, i|
      row.each.with_index do |value, j|
        yield value, i, j
      end
    end
  end
end

class Cell
  getter number : Int32
  getter marked : Bool

  def initialize(@number)
    @marked = false
  end

  def ==(value : Int32)
    number == value
  end

  def mark!(value = true)
    @marked = value
  end

  def marked? : Bool
    @marked
  end
end

lines = File.read_lines("input.txt")

chosen_numbers = lines.shift.split(',').map(&.to_i)

# Reading Input
boards = [] of Board
current_board = [] of Array(Cell)
lines.each do |line|
  next if line.blank?

  row = line.strip
    .split(/\s+/)
    .map(&.strip)
    .map(&.to_i)
    .map { |n| Cell.new(n) }

  current_board << row

  if current_board.size == 5
    boards << Board.new(current_board)
    current_board = [] of Array(Cell)
  end
end

# Part 1
chosen_numbers.each do |number|
  marked = boards.select(&.mark(number))

  winning_board = boards.find(&.won?)

  if winning_board
    puts "Winning board score: #{winning_board.score}"
    break
  end
end

# Part 2
boards.each(&.reset!)

recent_win = nil

chosen_numbers.each do |number|
  boards = boards.reject do |board|
    if board.won?
      recent_win = board
      true
    end
  end

  boards.each(&.mark(number))
end

if recent_win
  puts "Last board to win score: #{recent_win.score}"
else
  puts "no recent win"
end

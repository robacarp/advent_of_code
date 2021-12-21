require "../kit"

class Point
  property x : Int32
  property y : Int32

  def initialize(@x, @y)
  end

  def ==(other : self)
    x == other.x && y == other.y
  end

  def_hash @x, @y

  def to_s(io : IO)
    io << "("
    io << x
    io << ","
    io << y
    io << ")"
  end

  def adjust(by : self)
    self.class.new(x + by.x, y + by.y)
  end

  delegate inspect, to: to_s
end

alias Velocity = Point
alias CoordRange = Range(Int32, Int32)

struct Range(B, E)
  def self.from_s(string) : self
    exclusive = false
    start, finish = string.split ".."

    if finish[0] == '.'
      finish = finish.lstrip '.'
      exclusive = true
    end

    new start.to_i, finish.to_i, exclusive
  end
end


class Probe
  getter position : Point
  getter velocity : Velocity

  include Iterator(Int32)

  def initialize(@position : Point, initial_velocity : Velocity)
    @velocity = initial_velocity.dup
  end

  # increments the probe and yields at every step
  def next
    # The probe's x position increases by its x velocity.
    position.x += velocity.x

    # The probe's y position increases by its y velocity.
    position.y += velocity.y

    # Due to drag, the probe's x velocity changes by 1 toward the value 0; that is, it decreases by 1 if it is greater than 0, increases by 1 if it is less than 0, or does not change if it is already 0.
    case velocity.x
    when .> 0
      velocity.x -= 1
    when .< 0
      velocity.x += 1
    end

    # Due to gravity, the probe's y velocity decreases by 1.
    velocity.y -= 1

    position.dup
  end
end

class Trajectory
  getter velocity : Velocity
  getter points : Array(Point)
  getter target : {CoordRange, CoordRange}

  def initialize(velocity : Point, @target)
    @velocity = velocity.dup
    @points = [] of Point
  end

  def fire
    probe = Probe.new Point.new(0,0), velocity

    loop do
      if points.any?
        break if overshot?
        break if successful?
        break if undershot?
        break if indeterminate_miss?
      end

      points << probe.next
    end
  end

  def overshot? : Bool
    max_x = target[0].max
    points_in_y_window = points.select {|p| target[1].includes? p.y}
    return false if points_in_y_window.none?
    sample_point = points_in_y_window.first
    sample_point.x > max_x
  end

  def undershot? : Bool
    points_in_y_window = points.select {|p| target[1].includes? p.y}
    min_x = target[0].min
    return false if points_in_y_window.none?
    sample_point = points_in_y_window.first
    sample_point.x < min_x
  end

  def indeterminate_miss? : Bool
    return false unless points.size > 2
    p1, p2 = points.last(2)
    # the probe must be moving down
    return false unless p1.y > p2.y

    # is the last point below the target boundary?
    sample_point = points.last
    min_y = target[1].min
    sample_point.y < min_y
  end

  def successful? : Bool
    target[0].includes?(points.last.x) && target[1].includes?(points.last.y)
  end

  def <=>(other : self)
    sort_key <=> other.sort_key
  end

  def sort_key
    if target_delta == 0
      highest_point.y
    else
      target_delta * -10
    end
  end

  def target_delta : Int32
    min_x = target.first.begin
    max_x = target.first.end
    min_y = target.last.begin
    max_y = target.last.end

    point = points.last
    delta = 0

    if point.x < min_x
      delta +=  min_x - point.x
    elsif point.x > max_x
      delta +=  point.x - max_x
    end

    if point.y < min_y
      delta +=  min_y - point.y
    elsif point.y > max_y
      delta +=  point.y - max_y
    end

    delta
  end

  def highest_point : Point
    points.sort_by(&.y).last
  end

  def inspect(io : IO)
    io << "<max:"
    io << highest_point.y
    io << " hit".colorize.red if successful?
    io << " points:"
    io << points.size
    io << " velocity:"
    io << velocity
    io << " sort_key:"
    io << sort_key
    io << ">"
  end

  delegate to_s, to: inspect

  def debug
    height = highest_point.y
    width
  end
end

class Solver
  BREAKPOINT = 10000

  getter target : {CoordRange, CoordRange}
  getter solutions
  getter attempted_velocities
  getter initial_velocity

  def initialize(@target)
    @solutions = [] of Trajectory
    @attempted_velocities = Set(Velocity).new
    @initial_velocity = Velocity.new(0,0)
  end

  def solve
    best = Trajectory.new @initial_velocity, target
    best.fire

    trajectories = [] of Trajectory
    increments = [ Point.new(2,1), Point.new(1,1), Point.new(1,2) ]

    no_improvement_count = 0

    loop do
      trajectories.clear

      increments.each do |increment|
        velocity = best.velocity.adjust(increment)
        next if attempted_velocities.includes? velocity
        attempted_velocities << velocity
        trajectories << Trajectory.new velocity, target
      end

      trajectories.each do |trajectory|
        trajectory.fire
        solutions << trajectory if trajectory.successful?
      end

      new_best = [trajectories, best].flatten.sort.last

      if new_best == best
        no_improvement_count += 1
        break if no_improvement_count > 3
        increments.map {|p| Point.new p.x * 2, p.y * 2 }
        (1..3).each do |n|
          increments << Point.new(0, n)
          increments << Point.new(n, 0)
          increments << Point.new(n, n)
        end
      else
        no_improvement_count = 0
        delta = Point.new(new_best.velocity.x - best.velocity.x, new_best.velocity.y - best.velocity.y)
        increments = [
          Point.new(0, delta.y),
          Point.new(0, delta.y * 2),
          Point.new(delta.x, 0),
          Point.new(delta.x * 2, 0),
          Point.new(delta.x, delta.y),
          Point.new(delta.x * 2, delta.y * 2)
        ]
      end

      increments = increments.uniq.reject {|p| p.x == 0 && p.y == 0 }

      best = new_best
    end
  end

  def successful?
    @solutions.any? &.successful?
  end

  def sorted_solutions
    @solutions.sort
  end
end

puzzle "TrickShot" do
  test "45" do
    "target area: x=20..30, y=-10..-5"
  end

  input do
    "target area: x=57..116, y=-198..-148"
  end

  solve do |input|
    _, area = input.split ": "
    x_range, y_range = area.split(", ").map(&.split('=').last).map { |string_range| Range.from_s string_range }
    s = Solver.new({x_range, y_range})
    s.solve
    puts "solver found #{s.solutions.size} correct solutions."
    best = s.sorted_solutions.last
    best.highest_point.y
  end
end


require "colorize"

data = File.read_lines("testing.txt")
data = File.read_lines("testing2.txt")
data = File.read_lines("testing3.txt")
data = File.read_lines("input.txt")

class Cave
  enum Type
    Large
    Small
    Start
    End
  end

  SMALL_DETECTOR = /[a-z]/

  property type : Type
  property name : String
  property connections = [] of self

  def initialize(@name)
    @type = case @name
            when "start" then Type::Start
            when "end" then Type::End
            when SMALL_DETECTOR then Type::Small
            else
              Type::Large
            end
  end

  def connect(to other_cave)
    connections << other_cave
  end

  def navigate(to destination, path_to_me = "", visited = [] of self) : Array(String)
    visited << self

    path_to_me = [path_to_me, name].reject(&.blank?).join ','
    return [path_to_me] if self.name == destination
    # print path_to_me

    paths = connections.map do |cave|
      # print "(->#{cave.name})"

      next nil unless cave.can_visit? visited

      # puts "going!"

      cave.navigate to: destination, path_to_me: path_to_me, visited: visited.dup
    end.compact.flatten
  end

  def can_visit?(visited) : Bool
    case
    # I am a big cave
    when type == Type::Large
      true

    # Start and finish only once
    when type == Type::Start
      ! visited.includes? self
    when type == Type::End
      ! visited.includes? self

    # I am a small cave
    # - has a small cave has been visited twice?
    else
      # I have not been visited
      if ! visited.includes? self
        true

      else
        visit_counts_of_small_caves = visited
          .select{|c| c.type == Type::Small}
          .group_by(&.itself)
          .transform_values(&.size)

        # I have been visited, have any been visited twice?
        visit_counts_of_small_caves.values.max < 2
      end
    end
  end

  def to_s(io : IO)
    io << "<Cave "
    io << name
    io << " connects to: "
    io << connections.map(&.name)
    io << ">"
  end
end

class Caves
  @caves = {} of String => Cave

  def initialize
    @caves["start"] = Cave.new "start"
    @caves["end"] = Cave.new "end"
  end

  def connect(a, b)
    cave_a = @caves[a] ||= Cave.new a
    cave_b = @caves[b] ||= Cave.new b

    @caves[a].connect to: cave_b
    @caves[b].connect to: cave_a
  end

  def navigate
    paths = @caves["start"].navigate to: "end"
  end

  def to_s(io : IO)
    @caves.each do |name, cave|
      io << cave
      io << '\n'
    end
  end
end

cave_system = Caves.new

data.each do |path|
  start, finish = path.split '-'
  cave_system.connect start, finish
end

puts cave_system

paths = cave_system.navigate
pp paths.sort
puts "found #{paths.size} paths from start to end"

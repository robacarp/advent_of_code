require "../helper"

sample = <<-TEXT
vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw
TEXT

# puts 'a'.ord # 97
# puts 'A'.ord # 65
struct Char
  def priority
    v = ord
    v -= 96 if v >= 97
    v -= 38 if v >= 65
    v
  end
end

class Rucksack
  getter left : Array(Char)
  getter right : Array(Char)
  getter inventory : Array(Char)

  def initialize(string_inventory : String)
    initialize string_inventory.chars
  end

  def initialize(@inventory)
    size = inventory.size // 2
    @left = inventory[0...size]
    @right = inventory[size..-1]
    @collisions = @left & @right
  end

  def collision_priority : Int32
    @collisions.map(&.priority).sum
  end
end

class SackGroup
  getter sacks : Array(Rucksack)
  def initialize(sacks)
    @sacks = sacks
  end

  def collision_priority : Int32
    sacks.map(&.collision_priority).sum
  end

  def badge_priority : Int32
    inventories = sacks.map(&.inventory)
    badge = inventories[0] & inventories[1] & inventories[2]
    badge.map(&.priority).sum
  end
end

AOC["collision priority"].do do
  sacks = sample.lines.map do |inventory|
    Rucksack.new inventory
  end

  assert_equal 157, sacks.map(&.collision_priority).sum

  sacks = input.lines.map do |inventory|
    Rucksack.new inventory
  end

  display_solution sacks.map(&.collision_priority).sum
end

AOC["badge priority"].do do
  groups = sample.lines.map do |inventory|
    Rucksack.new inventory
  end.each_slice(3).map do |sacks|
    SackGroup.new sacks
  end

  assert_equal 70, groups.map(&.badge_priority).sum

  groups = input.lines.map do |inventory|
    Rucksack.new inventory
  end.each_slice(3).map do |sacks|
    SackGroup.new sacks
  end

  display_solution groups.map(&.badge_priority).sum
end

require "../helper"

sample = <<-TEXT
$ cd /
$ ls
dir a
14848514 b.txt
8504156 c.dat
dir d
$ cd a
$ ls
dir e
29116 f
2557 g
62596 h.lst
$ cd e
$ ls
584 i
$ cd ..
$ cd ..
$ cd d
$ ls
4060174 j
8033020 d.log
5626152 d.ext
7214296 k
TEXT

module AoC
  class File
    getter size : Int32
    def initialize(@name : String, @size)
    end
  end

  class Directory
    getter parent : Directory?
    getter name : String

    def initialize(@name, @parent = nil)
      @files = [] of File
      @directories = [] of Directory
    end

    def push(file : File)
      @files << file
    end

    def push(directory : Directory)
      @directories << directory
    end

    def cd(name : String) : Directory
      @directories.find! { |d| d.name == name }
    end

    def size : Int32
      @files.sum(&.size) + @directories.sum(&.size)
    end

    def all_directories : Array(Directory)
      dirs = [self] + @directories + @directories.flat_map(&.all_directories)
      dirs.uniq
    end

    def path : String
      if parent = @parent
        if parent.path == "/"
          "/#{name}"
        else
          "#{parent.path}/#{name}"
        end
      else
        "/"
      end
    end
  end

  class InputParser
    def initialize(@input : String)
    end

    def build_fs
      root = Directory.new("/")
      current = root

      @input.lines.each.with_index do |line, i|
        case
        when line =~ %r|^\$ cd /|
          current = root

        when line =~ /^\$ cd \.\./
          if parent = current.parent
            current = parent
          else
            raise "Cannot go up from root. pwd=#{current.path} i=#{i}"
          end

        when line =~ /^\$ cd /
          name = line.split(" ")[2]

          if next_dir = current.cd name
            current = next_dir
          else
            raise "Cannot find directory #{name}"
          end
        when line =~ /^\$ ls/
          # no-op
        when line =~ /^\d+/ # file
          size, name = line.split(" ")
          file = File.new name, size.to_i
          current.push file
        when line =~ /^dir/ # directory
          name = line.split(" ")[1]
          directory = Directory.new name, current
          current.push directory
        else
          raise "Unknown line: #{line}"
        end
      end

      root
    end
  end
end

AOC(Int32)["sum of directory sizes"].do do
  parser = AoC::InputParser.new(sample)
  root = parser.build_fs

  assert_equal 584, root.cd("a").cd("e").size, "size of /a/e"
  assert_equal 94853, root.cd("a").size, "size of /a"
  assert_equal 24933642, root.cd("d").size, "size of /d"
  assert_equal 48381165, root.size, "size of /"

  small_enough = root.all_directories
    .select(&.size.<=(100000))

  assert_equal 95437, small_enough.map(&.size).sum

  solve do
    parser = AoC::InputParser.new(input)
    root = parser.build_fs

    small_enough = root.all_directories
      .select(&.size.<=(100000))

    solution small_enough.map(&.size).sum
  end
end

AOC(Int32)["smallest dir which will free up enough space"].do do
  total_disk_size = 70000000
  update_required = 30000000

  parser = AoC::InputParser.new(sample)
  root = parser.build_fs

  space_used = root.size
  space_free = total_disk_size - space_used
  space_needed = update_required - space_free

  assert_equal 48381165, space_used, "space used"
  assert_equal 21618835, space_free, "space free"
  assert_equal 8381165, space_needed, "space needed"

  big_enough = root.all_directories
    .select(&.size.>=(space_needed))

  assert_equal 24933642, big_enough.sort(&.size).last.size

  solve do
    parser = AoC::InputParser.new(input)
    root = parser.build_fs

    space_used = root.size
    space_free = total_disk_size - space_used
    space_needed = update_required - space_free

    big_enough = root.all_directories
      .select(&.size.>=(space_needed))

    solution big_enough.sort(&.size).last.size
  end
end

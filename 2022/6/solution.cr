require "../helper"

class MessageDecoder
  def initialize(@message : String)
  end

  def start_of_packet
    @message.chars.each_cons(4).with_index do |quad, offset|
      return offset + 4 if quad.uniq.size == 4
    end
  end

  def start_of_message
    @message.chars.each_cons(14).with_index do |quad, offset|
      return offset + 14 if quad.uniq.size == 14
    end
  end
end

AOC(Int32)["stack toppers"].do do
  assert_equal 7, MessageDecoder.new("mjqjpqmgbljsphdztnvjfqwrcgsmlb").start_of_packet
  assert_equal 5, MessageDecoder.new("bvwbjplbgvbhsrlpgdmjqwftvncz").start_of_packet
  assert_equal 6, MessageDecoder.new("nppdvjthqldpwncqszvftbrmjlhg").start_of_packet
  assert_equal 10, MessageDecoder.new("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg").start_of_packet
  assert_equal 11, MessageDecoder.new("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw").start_of_packet

  solve do
    solution MessageDecoder.new(input).start_of_packet
  end
end

AOC(Int32)["stack toppers"].do do
  assert_equal 19, MessageDecoder.new("mjqjpqmgbljsphdztnvjfqwrcgsmlb").start_of_message
  assert_equal 23, MessageDecoder.new("bvwbjplbgvbhsrlpgdmjqwftvncz").start_of_message
  assert_equal 23, MessageDecoder.new("nppdvjthqldpwncqszvftbrmjlhg").start_of_message
  assert_equal 29, MessageDecoder.new("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg").start_of_message
  assert_equal 26, MessageDecoder.new("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw").start_of_message

  solve do
    solution MessageDecoder.new(input).start_of_message
  end
end

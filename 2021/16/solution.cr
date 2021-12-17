require "colorize"
require "big"

TESTING = false

def only_testing
  yield if true #TESTING
end

def yolo(*args)
  only_testing do
    puts *args
  end
end

abstract class Packet
  getter version : Int32
  getter type : Int32

  def initialize(@version : Int32, @type : Int32, bits : Array(Char))
  end

  def self.build(bits : Array(Char)) : Packet
    version = bits.shift(3).join.to_i(2)
    type = bits.shift(3).join.to_i(2)

    if type == 4
      ValuePacket.new(version, type, bits)
    else
      OpPacket.new(version, type, bits)
    end
  end

  def version_sum
    version
  end
end

class ValuePacket < Packet
  getter value : Int64

  def initialize(@version : Int32, @type : Int32, bits : Array(Char))
    value_bits = [] of Char

    loop do
      stop_bit = bits.shift
      value_bits += bits.shift(4)
      if stop_bit == '0'
        break 
      end
    end

    @value = value_bits.join.to_i64(2)
  end
end

class OpPacket < Packet
  getter length : Int32
  getter packets = [] of Packet

  def initialize(@version : Int32, @type : Int32, bits : Array(Char))
    length_bitlength = 15
    length_type = bits.shift
    length_bitlength = 11 if length_type == '1'
    @length = bits.shift(length_bitlength).join.to_i(2)

    if length_type == '0' # length is a literal number of bits
      sub_packets = bits.shift(@length)

      while sub_packets.any?
        packets << (p = Packet.build sub_packets)
      end
    else # length is a number of 11-bit(?) packets
      @length.times do
        packets << (p = Packet.build bits)
      end
    end
  end

  def value : Int64
    case @type
    when 0 # add
      packets.reduce(0.to_i64) {|sum, packet| sum += packet.value}
    when 1 # multiply
      packets.reduce(1.to_i64) {|product, packet| product *= packet.value}
    when 2 # min
      packets.min_by(&.value).value
    when 3 # max
      packets.max_by(&.value).value
    when 4 # ??
      raise "this isn't a thing"
    when 5 # greater than -- 1 if first > second.
      if packets[0].value > packets[1].value
        1
      else
        0
      end
    when 6 # less than -- 1 if first < second.
      if packets[0].value < packets[1].value
        1
      else
        0
      end
    when 7 # equal -- 1 if first == second.
      if packets[0].value == packets[1].value
        1
      else
        0
      end
    else
      raise "this isn't a thing"
    end.to_i64
  end

  def version_sum
    packets.map(&.version_sum).sum + version
  end
end

class Message
  getter packet : Packet

  def initialize(@data : String)
    bitstream = data.chars.map(&.to_i64(16).to_s(2, precision: 4)).join.chars
    @packet = Packet.build bitstream
  end

  delegate version_sum, value, to: @packet
end

m = Message.new("D2FE28").packet
puts "#{m.version}.should be(6)"
puts "#{m.type}.should be(4)"
puts "#{m.as(ValuePacket).value}.should be 2021"

Message.new("EE00D40C823060")
Message.new("38006F45291200")
puts "should be 16 #{Message.new("8A004A801A8002F478").version_sum}"
puts "should be 12 #{Message.new("620080001611562C8802118E34").version_sum}"
puts "should be 23 #{Message.new("C0015000016115A2E0802F182340").version_sum}"
puts "should be 31 #{Message.new("A0016C880162017C3686B18A3D4780").version_sum}"

puts "should be 3 #{Message.new("C200B40A82").value}"
puts "should be 54 #{Message.new("04005AC33890").value}"
puts "should be 7 #{Message.new("880086C3E88112").value}"
puts "should be 9 #{Message.new("CE00C43D881120").value}"
puts "should be 1 #{Message.new("D8005AC2A8F0").value}"
puts "should be 0 #{Message.new("F600BC2D8F").value}"
puts "should be 0 #{Message.new("9C005AC2F8F0").value}"
puts "should be 1 #{Message.new("9C0141080250320F1802104A08").value}"

data = if TESTING
  File.read_lines("testing.txt")
else
  File.read_lines("input.txt")
end

message = Message.new data.join
puts "Message Version Sum: #{message.version_sum}"
puts "Message Value : #{message.value}"


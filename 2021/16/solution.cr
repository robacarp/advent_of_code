require "../kit"

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


puzzle "PacketDecoder" do
  test "16" { "8A004A801A8002F478" }
  test "12" { "620080001611562C8802118E34" }
  test "23" { "C0015000016115A2E0802F182340" }
  test "31" { "A0016C880162017C3686B18A3D4780" }

  input do
    File.read_lines("input.txt").join
  end

  output do |value|
    "Message Version Sum: #{value}"
  end

  solve do |input|
    Message.new(input).version_sum
  end
end

puzzle "PacketDecoderValue" do
  test "3" { "C200B40A82" }
  test "54" { "04005AC33890" }
  test "7" { "880086C3E88112" }
  test "9" { "CE00C43D881120" }
  test "1" { "D8005AC2A8F0" }
  test "0" { "F600BC2D8F" }
  test "0" { "9C005AC2F8F0" }
  test "1" { "9C0141080250320F1802104A08" }

  input do
    File.read_lines("input.txt").join
  end

  output do |value|
    "Message Value: #{value}"
  end

  solve do |input|
    Message.new(input).value
  end
end

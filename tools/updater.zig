const std = @import("std");
const Ringbuffer = @import("shared").collections.RingBuffer;
const assert = std.debug.assert;
const zig_serial = @import("serial");

// Constants for the packet protocol
const PACKET_LENGTH_BYTES: u32   = 1;
const PACKET_DATA_BYTES: u32     = 16;
const PACKET_CRC_BYTES: u32      = 1;
const PACKET_CRC_INDEX: u32      = PACKET_LENGTH_BYTES + PACKET_DATA_BYTES;
const PACKET_LEN: u32         = PACKET_LENGTH_BYTES + PACKET_DATA_BYTES + PACKET_CRC_BYTES;

const PACKET_ACK_DATA0: u8     = 0x15;
const PACKET_RETX_DATA0: u8     = 0x19;


// Details about the serial port connection
const serial_path            = "/dev/ttyACM0";
const baud_rate              = 115200;

const ACK_DEFAULT: Packet = Packet.init(1, [_]u8{PACKET_ACK_DATA0} ++ [_]u8{0xFF} ** 15, null);
const RETX_DEFAULT: Packet = Packet.init(1, [_]u8{PACKET_RETX_DATA0} ++ [_]u8{0xFF} ** 15, null);

fn crc8(data: []const u8) u8 {
    var crc: u8 = 0;
    for (data) |byte| {
        crc ^= byte;
        for (0..8) |_| {
            if (crc & 0x80 != 0) {
                crc = (crc << 1) ^ 0x07;
            } else {
                crc <<= 1;
            }
        }
    }
    return crc;
}

/// | pack_len (1 * u8) | data (16 * u8) | CRC (1 * u8) | 
const Packet = struct {
    const Self = @This();
    length: u8,
    data: [PACKET_DATA_BYTES]u8,
    /// Cyclical Redudancy Check (basically a validation hash)
    crc: u8,
    /// Retransmission packet
    retx: ?*const Packet,
    /// Acknowledgement packet
    ack: ?*const Packet,

    pub fn init(length: u8, data: [PACKET_DATA_BYTES]u8, crc: ?u8) Packet {
        var new_crc: u8 = 0;
        if (crc == null) {
            var crc_buf = [_]u8{length} ++ data;
            @memcpy(crc_buf[1..], data[0..PACKET_DATA_BYTES]);
            new_crc = crc8(&crc_buf);
        }

        return Packet {
            .length = length,
            .data = data,
            .crc = crc orelse new_crc,
            .retx = null,
            .ack = null,
        };
    }

    pub fn to_buffer(self: Self, buffer: *[PACKET_LEN]u8) void {
        // assert(self.length == PACKET_LEN);
        buffer[0] = self.length;
        @memcpy(buffer[1..PACKET_DATA_BYTES+1], self.data[0..]);
        buffer[PACKET_CRC_INDEX] = self.crc;
    }

    pub fn from_buffer(buffer: *const [PACKET_LEN]u8) Self {
        var data: [PACKET_DATA_BYTES]u8 = undefined; 
        @memcpy(data[0..], buffer[1..17]);

        var new = Packet {
            .length = buffer[0],
            .data = data,
            .crc = buffer[PACKET_LEN-1],
            .retx = if (Self.single_byte_packet(buffer, PACKET_RETX_DATA0)) &RETX_DEFAULT else null,
            .ack = if (Self.single_byte_packet(buffer, PACKET_ACK_DATA0)) &ACK_DEFAULT else null,
        };

        if (buffer[1] == PACKET_ACK_DATA0) {
            new.ack = &Packet.init(1, [_]u8{PACKET_ACK_DATA0} ++ [_]u8{0xFF} ** 15, null);
        } else if (buffer[1] == PACKET_RETX_DATA0) {
            new.retx = &Packet.init(1, [_]u8{PACKET_RETX_DATA0} ++ [_]u8{0xFF} ** 15, null);
        }
        
        return new;
    }

    pub fn single_byte_packet(buffer: *const [PACKET_LEN]u8, byte: u8) bool {
        if (buffer[0] != 1) return false;
        if (buffer[1] != byte) return false;
        for (1..PACKET_DATA_BYTES+1) |i| {
            if (buffer[i] != 0xFF) return false;
        }
        return true;
    }

};



var packets: [100]Packet = undefined;
var rx_buffer = Ringbuffer(u8, 32).init();

pub fn main() !void {
    // var buffer: [PACKET_LEN]u8 = undefined;
    // var pack = Packet.init(1, [_]u8{PACKET_RETX_DATA0} ++ [_]u8{0xFF} ** 15, null);
    //
    // pack.retx = &Packet.init(1, [_]u8{PACKET_RETX_DATA0} ++ [_]u8{0xFF} ** 15, null);
    // pack.ack = &Packet.init(1, [_]u8{PACKET_ACK_DATA0} ++ [_]u8{0xFF} ** 15, null);
    //
    // pack.retx.?.*.to_buffer(&buffer);



    var serial = try std.fs.cwd().openFile(serial_path, .{ .mode = .read_write }) ;
    defer serial.close();

    try zig_serial.configureSerialPort(serial, zig_serial.SerialConfig{
        .baud_rate = 115200,
        .word_size = .eight,
        .parity = .none,
        .stop_bits = .one,
        .handshake = .none,
    });

    std.debug.print("Waiting for data...\n", .{});

    while (true) {
        const data = try serial.reader().readByte();
        rx_buffer.non_blocking_write(data);
        
        if (rx_buffer.length < PACKET_LEN) continue;

        var temp_pack_buf: [PACKET_LEN]u8 = undefined;

        for (0..PACKET_LEN) |i| {
            // std.debug.print("Received {any} packet through UART\n", .{byte});
            temp_pack_buf[i] = rx_buffer.read().?;
        }

        // const rx_packet = Packet.from_buffer(&rx_buffer[0..18]);
        std.debug.print("Received {any} packet through UART\n", .{temp_pack_buf});
    }
}

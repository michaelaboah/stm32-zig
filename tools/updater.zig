const std = @import("std");
const zig_serial = @import("serial");

// Constants for the packet protocol
const PACKET_LENGTH_BYTES: u32   = 1;
const PACKET_DATA_BYTES: u32     = 16;
const PACKET_CRC_BYTES: u32      = 1;
const PACKET_CRC_INDEX: u32      = PACKET_LENGTH_BYTES + PACKET_DATA_BYTES;
const PACKET_LENGTH: u32         = PACKET_LENGTH_BYTES + PACKET_DATA_BYTES + PACKET_CRC_BYTES;

const PACKET_ACK_DATA0: u8     = 0x15;
const PACKET_RETX_DATA0: u8     = 0x19;


// Details about the serial port connection
const serial_path            = "/dev/ttyACM0";
const baud_rate              = 115200;


pub const Packet = struct {
    const Self = @This();
    length: u8,
    data: [PACKET_DATA_BYTES]u8,
    crc: u8,

    // Static instances for `retx` and `ack`
    pub const retx = Packet.init(1, [_]u8{PACKET_RETX_DATA0}, null);
    pub const ack = Packet.init(1, [_]u8{PACKET_ACK_DATA0}, null);

    pub fn init(length: u8, data: []const u8, crc: ?u8) Packet {
        var padded_data: [PACKET_DATA_BYTES]u8 = undefined;

        // Copy provided data into the padded array and pad with 0xFF.
        var i: usize = 0;
        while (i < data.len and i < PACKET_DATA_BYTES) : (i += 1) {
            padded_data[i] = data[i];
        }
        while (i < PACKET_DATA_BYTES) : (i += 1) {
            padded_data[i] = 0xFF;
        }

        return Packet{
            .length = length,
            .data = padded_data,
            .crc = crc orelse Packet.computeCrc(length, &padded_data),
        };
    }

    // Computes the CRC for the packet
    fn computeCrc(length: u8, data: *const [PACKET_DATA_BYTES]u8) u8 {
        var all_data: [PACKET_DATA_BYTES + 1]u8 = undefined;
        all_data[0] = length;
        @memcpy(all_data[1..], data);
        return crc8(all_data[0..]);
    }

    // Converts the packet to a buffer representation
    pub fn toBuffer(self: Packet) [*]const u8 {
        var buffer: [1 + PACKET_DATA_BYTES + 1]u8 = undefined; // [length, data, crc]
        buffer[0] = self.length;
        @memcpy(buffer[1..1 + PACKET_DATA_BYTES], self.data[0..]);
        buffer[1 + PACKET_DATA_BYTES] = self.crc;
        return &buffer;
    }

    fn is_single_byte_packet(self: Self, byte: u8) bool {
        if (self.length != 1) return false;
        if (self.data[0] != byte) return false;
        for (1..PACKET_DATA_BYTES) |i| {
            if (self.data[i] != 0xFF) return false;
        }
        return true;
    }

    pub fn is_ack(self: Self) bool {
        return self.is_single_byte_packet(PACKET_ACK_DATA0);
    }

    pub fn is_retx(self: Self) bool {
        return self.is_single_byte_packet(PACKET_RETX_DATA0);
    }
};



fn crc8(data: []u8) u8 {
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

fn write_packet(serial_port: *std.fs.File, packet: []const u8) void {
    serial_port.write(packet);
    last_packet = packet;
}


var last_packet: []Packet = Packet.ack;

pub fn main() !u8 {

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    const packets = std.ArrayList(Packet).init(alloc);
    defer packets.deinit();




    const port_name = if (@import("builtin").os.tag == .windows) "\\\\.\\COM1" else serial_path;

    var serial_port = std.fs.cwd().openFile(port_name, .{ .mode = .read_write}) catch |err| switch (err) {
        error.FileNotFound => {
            std.debug.print("Invalid config: the serial port '{s}' does not exist\n", .{port_name});
            return 1;
        },
        else => return err
    };

    defer serial_port.close();

    // write_packet(&serial_port, packet: []const u8)

    try zig_serial.configureSerialPort(serial_port, zig_serial.SerialConfig{
        .baud_rate = baud_rate,
        .word_size = .eight,
        .parity = .none,
        .stop_bits = .one,
        .handshake = .none,
    });

    const t = [1]u8{PACKET_RETX_DATA0};
    const retx = Packet.init(1, &t, null);
    std.debug.print("Hello World {any}\n", .{retx.data});    

    return 0;
}

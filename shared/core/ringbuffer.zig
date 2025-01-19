pub fn RingBuffer(comptime T: type, size: comptime_int) type {
    return struct {
        const Self = @This();

        read_index: usize,
        write_index: usize,
        buffer: [size]T,
        length: usize,
        /// For resetting the write head
        /// Since this is Zig &= or some wrapping operation could be used, but I wanted to represent a C way of doing things
        mask: usize,

        pub fn init() Self {
            return Self{
                .read_index = 0,
                .write_index = 0,
                .buffer = undefined,
                .length = 0,
                .mask = size - 1,
            };
        }

        // 0b0000 = 0b1000 & 0b0111;
        pub fn blocking_write(self: *Self, item: T) ?void {
            const next_write_index = (self.write_index+1) & self.mask;

            if (next_write_index == self.read_index) {
                // Write head cannot be equal or ahead of Read Head
                // Invalidated ring buffer
                return null;
            }


            self.buffer[self.write_index] = item;
            self.write_index = next_write_index;
            self.length += 1;
        }

        /// Return old data, could also just discard
        pub fn non_blocking_write(self: *Self, item: T) void {
            const next_write_index = (self.write_index+1) & self.mask;
            // var old_value: ?T = null;

            // Overwrite data in read_index
            if (next_write_index == self.write_index) {
                // old_value = self.buffer[self.read_index];
                self.read_index = (self.read_index + 1) & self.mask;
                // self.write_index = ne
            }

            self.buffer[self.write_index] = item;
            self.write_index = next_write_index;

            if (self.length < self.buffer.len) {
                self.length += 1;
            }
        }

        
        pub fn read(self: *Self) ?T {
            if (self.read_index == self.write_index) {
                // Buffer empty
                return null;
            }

            const value = self.buffer[self.read_index];
            self.read_index = (self.read_index + 1) & self.mask;
            self.length -= 1;
            return value;
        }


        /// Reset indices to 0 and drop buffer
        pub fn clear(self: *Self) void {
            self.write_index = 0;
            self.read_index = 0;
            self.buffer = undefined;
        }
    };
}





const std = @import("std");
const testing = std.testing;
const mem = std.mem;
const print = std.debug.print;



// Expected behavior: Write and Read integer
test "write" {
    var r = RingBuffer(u8, 8).init();
    
    _ = r.blocking_write(32);

    try testing.expect(32 == r.read());

    r.clear();

    _ = r.blocking_write(32);

    // print("{any}\n", .{r.buffer});
    try testing.expect(32 == r.read());

    // Expected behavior: Write and Read non-integer
    // test "insertion non-integer" {

    var ri = RingBuffer([]const u8, 8).init();
    
    _ = ri.blocking_write("hello");

    // print("{any}\n", .{ring.buffer});
    try testing.expectEqual("hello", ri.read().?);

    // Expected behavior: Write and Read non-integer
    // test "insertion Type" {

    const Packet = struct { byte: u8 };

    var rin = RingBuffer(Packet, 8).init();
    
    _ = rin.blocking_write(Packet{.byte = 'U'});

    try testing.expectEqualDeep(Packet{.byte = 'U'}, rin.read().?);


    // Expected behavior: Write and Read integer
    // test "insertion non-blocking" {

    var ring = RingBuffer(u8, 8).init();
    
    _ = ring.non_blocking_write(32);

    // print("{any}\n", .{ring.buffer});
    try testing.expect(32 == ring.read());



    // Expected behavior: Write and Read non-integer
    // test "insertion non-blocking non-integer" {
    
    var rb = RingBuffer([]const u8, 8).init();
    
    _ = rb.non_blocking_write("hello");

    // print("{any}\n", .{ring.buffer});
    try testing.expectEqual("hello", rb.read().?);


    // Expected behavior: Write and Read non-integer
    // test "insertion non-blocking Type" {

    var rbg = RingBuffer(Packet, 8).init();
    
    _ = rbg.non_blocking_write(Packet{.byte = 'U'});

    try testing.expectEqualDeep(Packet{.byte = 'U'}, rbg.read().?);
}

test "overflow" {
    var ring = RingBuffer(usize, 16).init();

    for (0..18) |i| {
        _ = ring.blocking_write(@intCast(i));
    }

    // print("{any}\n", .{ring.buffer});

    try testing.expect(ring.buffer[9] == 9);
    try testing.expect(ring.buffer[0] == 16);
    try testing.expect(ring.buffer[1] == 17);
    try testing.expect(ring.buffer[2] == 2);
}

// Expected behavior: 
test "insertion at overflow - blocking" {
    var ring = RingBuffer(usize, 16).init();

    for (0..18) |i| {
        _ = ring.blocking_write(@intCast(i));
    }

    try testing.expect(ring.buffer[9] == 9);
    try testing.expect(ring.buffer[0] == 16);
    try testing.expect(ring.buffer[1] == 17);
    try testing.expect(ring.buffer[2] == 2);
}

// Expected behavior: 
test "insertion at overflow - non-blocking" {
    var ring = RingBuffer(usize, 16).init();

    for (0..31) |i| {
        _ = ring.non_blocking_write(@intCast(i));

        if (i == 22) {
            for (0..5) |_| {
                _ = ring.read();
            }
        _ = ring.non_blocking_write(@intCast(100));
        }
    }

    print("{any}\n", .{ring.read().?});
    // 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
    // 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31
    try testing.expect(ring.buffer[5] == 22);
    try testing.expect(ring.read().? == 21);
    // try testing.expect(ring.buffer[1] == 17);
    // try testing.expect(ring.buffer[2] == 2);
}

test "read from empty" {}

test "index integrity after operations" {}

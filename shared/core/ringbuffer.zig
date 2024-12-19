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

        fn init() Self {
            return Self{
                .read_index = 0,
                .write_index = 0,
                .buffer = [_]T {0} ** size,
                .length = 0,
                .mask = size - 1,
            };
        }

        fn write(self: *Self, item: T) ?void {

            // 0b0000 = 0b1000 & 0b0111;

            if (self.write_index == self.mask) {
                // Write head cannot be equal or ahead of Read Head
                // Invalidated ring buffer
                return null;
            }

            self.buffer[self.write_index] = item;

            self.write_index = (self.write_index+1) & self.mask;
        }

        fn read(self: *Self) ?T {
            // Buffer is empty
            if (self.read_index == self.write_index) return null;

            defer self.read_index = (self.read_index+1) & self.mask;

            return self.buffer[self.read_index];
        }
    };
}

const testing = @import("std").testing;

test "insertion" {
    var ring = RingBuffer(u8, 8).init();
    
    ring.write(32).?;

    try testing.expect(32 == ring.read());
}

test "deletion" {
    var ring = RingBuffer(u8, 8).init();
    
    ring.write(32).?;

    try testing.expect(32 == ring.buffer[0]);
    try testing.expect(32 == ring.read().?);

}

test "overflow" {
    var ring = RingBuffer(usize, 10).init();

    for (0..12) |i| {
        ring.write(@intCast(i)).?;
    }

    try testing.expect(ring.buffer[9] == 9);
}

test "insertion at overflow" {}

test "read from empty" {}

test "index integrity after operations" {}

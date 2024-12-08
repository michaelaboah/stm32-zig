const MAP = @import("shared").MAP;
const vector = @import("vector_table.zig");
comptime {
    @import("startup.zig").export_start_symbol();
    @import("vector_table.zig").export_vector_table();
}

const BOOTLOADER_SIZE: u32 = 0x8000;
const FIRMWARE_START: u32 = BOOTLOADER_SIZE + MAP.FLASH_BASE;


fn jump_to_main() void {
    const main_vector_table: *vector.VectorTable = @ptrFromInt(FIRMWARE_START);
    main_vector_table.reset();
}

export fn main() callconv(.C) void {
    jump_to_main();
}

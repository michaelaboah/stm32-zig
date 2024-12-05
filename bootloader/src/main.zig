comptime {
    @import("startup.zig").export_start_symbol();
    // @import("vector_table.zig").export_vector_table();
}

export fn main() callconv(.C) noreturn {
    while (true) {
    }
}

const MAP = @import("shared").MAP;

const VTOR: *volatile u32 = @ptrFromInt(MAP.SCB.VTOR);

/// 
pub fn setup(boot_size: u32) void {
    VTOR.* = boot_size;
}

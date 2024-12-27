pub const MAP = @import("core/memory_map.zig");
pub const GPIO = @import("core/gpio.zig");
pub const RCC = @import("core/rcc.zig");
pub const SYS = @import("core/system.zig");
pub const COMM = struct {
    pub const USART = @import("core/comm/usart.zig");
};


pub const MAP = @import("core/memory_map.zig");
pub const GPIO = @import("core/gpio.zig");
pub const RCC = @import("core/rcc.zig");
pub const SYS = @import("core/system.zig");
pub const COMM = struct {
    pub const USART = @import("core/comm/usart.zig");
};

pub fn PIN(bank: u8, num: u8) u16 {
    return (((bank - 'A') << 8) | (num));
}

pub fn PINNO(pin: u16) u16 {
    return pin & 0xFF;
}

pub fn PINBANK(pin: u16) u16 {
    return pin >> 8;
}

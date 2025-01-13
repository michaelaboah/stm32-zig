const map = @import("memory_map.zig");
pub const GPIOA_BASE: u32 = map.AHB1 + 0x0000;
pub const GPIOB_BASE: u32 = map.AHB1 + 0x0400;
pub const GPIOC_BASE: u32 = map.AHB1 + 0x0800;
pub const GPIOD_BASE: u32 = map.AHB1 + 0x0C00;
pub const GPIOE_BASE: u32 = map.AHB1 + 0x1000;
pub const GPIOF_BASE: u32 = map.AHB1 + 0x1400;
pub const GPIOG_BASE: u32 = map.AHB1 + 0x1800;
pub const GPIOH_BASE: u32 = map.AHB1 + 0x1C00;



/// Represents the layout of a GPIO Port and its registers
pub const Port = struct {
    /// Mode Register
    MODER: u32,
    /// Output Type Register
    OTYPER: u32,
    /// Output Speed Register
    OSPEEDR: u32,
    /// Output Pull-up/Pull-down Register
    PUPDR: u32,
    /// Input Data Register
    IDR: u32,
    /// Output Data Register
    ODR: u32,
    /// Bit Set/Reset  Register
    BSRR: u32,
    /// Lock Register
    LCKR: u32,
    /// Alternate Function Low Register
    /// AFR[0] Handles pins 0..7
    /// AFR[1] Handles pins 8..15
    AFR: [2]u32,

    /// 
    pub inline fn set_mode(self: *volatile Port, pin: u8, mode: MODE) void {
        _ = 0b00000011_00000011;
        _ = 0b00000000_11111111;
        self.MODER &= ~(@as(u32, 3) << (pin) * 2);
        self.MODER |= (@intFromEnum(mode) & @as(u32, 3)) << (pin * 2);
    }

    /// Set Alternate Function
    pub inline fn set_af(self: *volatile Port, pin: u8, af_num: u8) void {
        // Note to self, anything pin below 7 or 0b0111 will result to 0 if (pin >> 3) and anything above will result to 1
        // Put another way (pin / 2^3) 
        // Everything in the () is to find the 4bit block we want and the clear it
        self.AFR[pin >> 3] &= ~(@as(u32, 15) << (pin & 7) * 4); // and shift into place by 2 (2^2) 
                                                      
        // Select the 4bit block and add the alternate function value (no overwriting)
        self.AFR[pin >> 3] |= @as(u32, af_num) << ((pin & 7) * 4);
    }
};

pub const MODE = enum(u8) {
    INPUT,
    OUTPUT,
    AF,
    ANALOG,
};


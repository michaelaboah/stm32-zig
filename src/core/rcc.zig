const MAP = @import("memory_map.zig");
pub const RCC_BASE: u32 = MAP.AHB1 + 0x3800;
/// RCC clock control register
pub const RCC_CR: u32 = RCC_BASE + 0x00;
/// RCC Reset Register
pub const RCC_AHB1_RSTR: u32 = RCC_BASE + 0x10;
/// RCC Reset Register
pub const RCC_AHB2_RSTR: u32 = RCC_BASE + 0x14;
/// RCC Reset Register
pub const RCC_AHB3_RSTR: u32 = RCC_BASE + 0x18;
/// RCC Reset Register
pub const RCC_APB1_RSTR: u32 = RCC_BASE + 0x20;
/// RCC Reset Register
pub const RCC_APB2_RSTR: u32 = RCC_BASE + 0x24;
/// RCC Enable Register
pub const RCC_AHB1_ENR: u32 = RCC_BASE + 0x30;
pub const RCC_AHB2_ENR: u32 = RCC_BASE + 0x34;
pub const RCC_APB3_ENR: u32 = RCC_BASE + 0x38;
pub const RCC_APB1_ENR: u32 = RCC_BASE + 0x40;
pub const RCC_APB2_ENR: u32 = RCC_BASE + 0x44;

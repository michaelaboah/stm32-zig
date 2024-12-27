const MAP = @import("memory_map.zig");

pub const RCC = struct {
    /// Control Register
    /// Offset: 0x00
    CR: u32,
    /// PLL Config Register
    /// Offset: 0x04
    PLLCFGR: u32,
    /// Clock Config Register
    /// Offset: 0x08
    CFGR: u32,
    /// Interrupt Register
    /// Offset: 0x0C
    CIR: u32,
    /// AHB1 Reset Register
    /// Offset: 0x10
    AHB1RSTR: u32,
    /// AHB2 Reset Register
    /// Offset: 0x14
    AHB2RSTR: u32,
    /// AHB3 Reset Register
    /// Offset: 0x18
    AHB3RSTR: u32,
    /// Offset: 0x1C
    RESERVED0: u32,
    /// APB1 Reset Register
    /// Offset: 0x20
    APB1RSTR: u32,
    /// APB2 Reset Register
    /// Offset: 0x24
    APB2RSTR: u32,
    /// Offset: 0x28
    /// Offset: 0x2C
    RESERVED1: [2]u32,
    /// AHB1 Enable Register
    /// Offset: 0x30
    AHB1ENR: u32,
    /// AHB2 Enable Register
    /// Offset: 0x34
    AHB2ENR: u32,
    /// AHB3 Enable Register
    /// Offset: 0x38
    AHB3ENR: u32,
    /// Offset: 0x3C
    RESERVED2: u32,
    /// APB1 Enable Register
    /// Offset: 0x40
    APB1ENR: u32,
    /// APB2 Enable Register
    /// Offset: 0x44
    APB2ENR: u32,
    /// Offset: 0x48
    /// Offset: 0x4C
    RESERVED3: [2]u32,
    /// AHB1 Low Power Mode Enable Register
    /// Offset: 0x50
    AHB1LPENR: u32,
    /// AHB2 Low Power Mode Enable Register
    /// Offset: 0x54
    AHB2LPENR: u32,
    /// AHB3 Low Power Mode Enable Register
    /// Offset: 0x58
    AHB3LPENR: u32,
    /// Offset: 0x5C
    RESERVED4: u32,
    /// APB1 Low Power Mode Enable Register
    /// Offset: 0x60
    APB1LPENR: u32,
    /// APB2 Low Power Mode Enable Register
    /// Offset: 0x64
    APB2LPENR: u32,
    /// Offset: 0x68
    /// Offset: 0x6C
    RESERVED5: [2]u32,
    /// Backup Domain Control Register
    /// Offset: 0x70
    BDCR: u32,
    /// Control & Status Register
    /// Offset: 0x74
    CSR: u32,
    /// Offset: 0x78
    /// Offset: 0x7C
    RESERVED6: [2]u32,
    /// Spread Spectrum Clock Generation Register
    /// Offset: 0x80
    SSCGR: u32,
    /// PLLI2S Config Register
    /// Offset: 0x84
    PLLI2SCFGR: u32,
    /// PLL Config Register
    /// Offset: 0x84
    PLLSAICFGR: u32,
    /// Dedicated Clock Config Register
    DCKCFGR: u32,
};

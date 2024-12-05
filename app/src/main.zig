const MAP = @import("shared").MAP;
comptime {
    @import("startup.zig").export_start_symbol();
    @import("vector_table.zig").export_vector_table();
}

// const MAX_BOOTLOADER_SIZE: u32 = 0x8000;
//
// export const bootloader_data: [MAX_BOOTLOADER_SIZE]u8 linksection(".bootloader_section") = v: {
//     const raw_bytes = @embedFile("bootloader");
//     var ret: [MAX_BOOTLOADER_SIZE]u8 = .{0} ** MAX_BOOTLOADER_SIZE;
//     @memcpy(ret[0..raw_bytes.len], raw_bytes);
//     break :v ret;
// };

const RCC_AHB1_ENR: *volatile u32 = @ptrFromInt(MAP.RCC_AHB1_ENR);
const GPIOA_MODER: *volatile u32 = @ptrFromInt(MAP.GPIOA_BASE + 0x00);
const GPIOA_OTYPER: *volatile u32 = @ptrFromInt(MAP.GPIOA_BASE + 0x04);
const GPIOA_OSPEEDR: *volatile u32 = @ptrFromInt(MAP.GPIOA_BASE + 0x08);
const GPIOA_PUPDR: *volatile u32 = @ptrFromInt(MAP.GPIOA_BASE + 0x0C);
/// Ouput Data Register
const GPIOA_ODR: *volatile u32 = @ptrFromInt(MAP.GPIOA_BASE + 0x14);

export fn main() callconv(.C) noreturn {
    
    RCC_AHB1_ENR.* |= 0x00000001;

    // Configure GPIOA Pin 5
    GPIOA_MODER.* &= 0xFFFFF3FF;  // Clear mode bits for Pin 5 (0b00).
    GPIOA_MODER.* |= 0x00000400;  // Set Pin 5 as output (0b01).

    GPIOA_OTYPER.* &= 0xFFFFFFDF; // Set Pin 5 as push-pull (clear bit 5).

    GPIOA_OSPEEDR.* &= 0xFFFFF3FF; // Clear speed bits for Pin 5 (0b00).
    GPIOA_OSPEEDR.* |= 0x00000800; // Set high speed for Pin 5 (0b10).

    GPIOA_PUPDR.* &= 0xFFFFF3FF;   // No pull-up/pull-down for Pin 5 (clear bits).

    while (true) {
        GPIOA_ODR.* ^= 0x00000020; // Toggle Pin 5 (bit 5).

        for (0..84000000/4) |_|{
            asm volatile ("nop");
        }
    }
}

// 00 08 01 02

const MAP = @import("shared").MAP;
const system = @import("core/system.zig");
const vector = @import("vector_table.zig");
comptime {
    @import("startup.zig").export_start_symbol();
    @import("vector_table.zig").export_vector_table();

    asm(
        \\.section .bootloader_section
        \\.incbin "zig-out/bin/bootloader.bin"
        );
}

const BOOT_SIZE: u32 = 0x8000;
const SYS_CLK_FREQ = 16_000_000;

const SCB_SHP3: *volatile u32 = @ptrFromInt(0xE000ED20);
const SYSTICK_CTRL: *volatile u32 = @ptrFromInt(0xE000ED10); // Sys CSR
const SYSTICK_LOAD: *volatile u32 = @ptrFromInt(0xE000ED14); // Sys RVR
const SYSTICK_VAL: *volatile u32 = @ptrFromInt(0xE000ED18);  // Sys CVR
// const SYSTICK_CR: *volatile u32 = @ptrFromInt(0xE000E01C);   // Sys Calibration


const RCC_AHB1_ENR: *volatile u32 = @ptrFromInt(MAP.RCC_AHB1_ENR);
const GPIOA_MODER: *volatile u32 = @ptrFromInt(MAP.GPIOA_BASE + 0x00);
const GPIOA_OTYPER: *volatile u32 = @ptrFromInt(MAP.GPIOA_BASE + 0x04);
const GPIOA_OSPEEDR: *volatile u32 = @ptrFromInt(MAP.GPIOA_BASE + 0x08);
const GPIOA_PUPDR: *volatile u32 = @ptrFromInt(MAP.GPIOA_BASE + 0x0C);
/// Ouput Data Register
const GPIOA_ODR: *volatile u32 = @ptrFromInt(MAP.GPIOA_BASE + 0x14);

const VTOR: *volatile u32 = @ptrFromInt(MAP.SCB.VTOR);

export fn main() callconv(.C) noreturn {

    // Offset vector_table to use firmware instead of bootloader which is default
    VTOR.* = BOOT_SIZE;

    // const desired_ticks: u32 = SYS_CLK_FREQ / 1000;
    SYSTICK_CTRL.* = 16000 - 1; // Number of CLK cycles the interrupt should fire after
    SCB_SHP3.* |= (0b11 << 6) << 24; // Setup systick to have a priority of 3;
    SYSTICK_VAL.* = 0; // Set counter back to 0;
    SYSTICK_CTRL.* = 0b111; // CLKSOURCE = 1 (processor clock), TICKINT = 1 (enable interrupt), ENABLE = 1 (enable systick
    // vector.vector_table.sys_tick = system.systick_handler;
    
    RCC_AHB1_ENR.* |= 0x00000001;


    // Configure GPIOA Pin 5
    GPIOA_MODER.* &= 0xFFFFF3FF;  // Clear mode bits for Pin 5 (0b00).
    GPIOA_MODER.* |= 0x00000400;  // Set Pin 5 as output (0b01).

    GPIOA_OTYPER.* &= 0xFFFFFFDF; // Set Pin 5 as push-pull (clear bit 5).

    GPIOA_OSPEEDR.* &= 0xFFFFF3FF; // Clear speed bits for Pin 5 (0b00).
    GPIOA_OSPEEDR.* |= 0x00000800; // Set high speed for Pin 5 (0b10).

    GPIOA_PUPDR.* &= 0xFFFFF3FF;   // No pull-up/pull-down for Pin 5 (clear bits).
                                   //

    while (true) {
        GPIOA_ODR.* ^= 0x00000020; // Toggle Pin 5 (bit 5).
                                   //
        // system.delay(1000);

        for (0..160000) |_|{
            asm volatile ("nop");
        }
    }
}

// 0xE000ED10

const map = @import("shared").MAP;
const gpio = @import("shared").GPIO;
const rcc = @import("shared").RCC;
const USART = @import("shared").COMM.USART;

const system = @import("core/system.zig");
const vector = @import("core/vector.zig");
const usart = @import("core/usart.zig");
const vector_table = @import("vector_table.zig");
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

const GpioA: *volatile gpio.Port  = @ptrFromInt(map.GPIOA_BASE + 0x00);  
const Rcc: *volatile rcc.RCC = @ptrFromInt(map.RCC_BASE);
const Usart2: *volatile USART.Usart = @ptrFromInt(map.USART2);

export fn main() callconv(.C) noreturn {
    vector.setup(BOOT_SIZE);
    const desired_ticks: u32 = SYS_CLK_FREQ / 1000;
    system.systick_setup(desired_ticks, 1, 1, 1);
    usart.setup();



    Rcc.*.AHB1ENR |= 0x01;
    

    // Configure GPIOA Pin 5
    GpioA.set_mode(5, .OUTPUT);

    while (true) {
        GpioA.*.ODR ^= (1 << 5); // Toggle Pin 5 (bit 5).
                                   //
        system.delay(1000);

        Usart2.write_buffer("Hello\n");
        // while () {
        // }
    }
}

// 0xE000ED10

extern fn main() noreturn;

pub fn export_start_symbol() void {
    @export(reset_handler, .{
        .name = "_start",
    });
}

/// Change Process State Interrupts Enable
/// Enable interrupts (clear PRIMASK.PM)
/// https://developer.arm.com/documentation/dui0662/b/The-Cortex-M0--Instruction-Set/Miscellaneous-instructions/CPS
pub inline fn enable_interrupts() void {
    asm volatile ("CPSIE i" ::: "memory");
}

/// Change Process State Interrupts Disable
/// Disable interrupts except NMI (set PRIMASK.PM)
/// https://developer.arm.com/documentation/dui0662/b/The-Cortex-M0--Instruction-Set/Miscellaneous-instructions/CPS
pub inline fn disable_interrupts() void {
    asm volatile ("CPSID i" ::: "memory");
}

pub fn reset_handler() callconv(.C) noreturn {
    const startup_symbols = struct {
        extern var _sbss: u8;
        extern var _ebss: u8;
        extern var _data: u8;
        extern var _edata: u8;
        extern const _data_loadaddr: u8;
    };

    // Ensure Interrupts are cleared
    disable_interrupts(); 
    {
        const bss_start: [*]u8 = @ptrCast(&startup_symbols._sbss);
        const bss_end: [*]u8 = @ptrCast(&startup_symbols._ebss);
        const bss_len = @intFromPtr(bss_end) - @intFromPtr(bss_start);

        // Init all global values to 0
        @memset(bss_start[0..bss_len], 0);
    }

    {
        const data_start: [*]u8 = @ptrCast(&startup_symbols._data);
        const data_end: [*]u8 = @ptrCast(&startup_symbols._edata);
        const data_len = @intFromPtr(data_end) - @intFromPtr(data_start);
        const data_src: [*]const u8 = @ptrCast(&startup_symbols._data_loadaddr);

        @memcpy(data_start[0..data_len], data_src[0..data_len]);
    }


    // Re-enable interrupts before calling main() 
    enable_interrupts();

    main();
}

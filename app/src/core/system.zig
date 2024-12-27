const map = @import("shared").MAP;
const sys = @import("shared").SYS;

const SCB_SHP3: *volatile u32 = @ptrFromInt(map.SCB.SHPR3);

var tick_counter: u32 = 0;


/// CLKSOURCE = 1 (processor clock), TICKINT = 1 (enable interrupt), ENABLE = 1 (enable systick
pub fn systick_setup(ticks: u32, clk_src: u32, tick_int: u32, enable: u32) void {
    const systick: *volatile sys.Systick = @ptrFromInt(map.SCS.STCSR); 
    systick.*.RVR = ticks;
    systick.*.CVR = 0;
    systick.*.CSR = (clk_src << 2) | (tick_int << 1) | (enable << 0); 
}


pub fn systick_handler() callconv(.C) void {
    tick_counter +%= 1;
}

pub fn get_ticks() u32 {
    return @as(*volatile u32, @ptrCast(&tick_counter)).*;
}

pub fn delay(milliseconds: u32) void {
    const start = get_ticks();
    // `-%` is to wrap
    while ((get_ticks() -% start) < milliseconds) {}
}


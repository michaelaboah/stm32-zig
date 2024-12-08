var ticks: u32 = 0;


pub fn systick_handler() callconv(.C) void {
    ticks += 1;
}

pub fn get_ticks() u32 {
    return @as(*volatile u32, @ptrCast(&ticks)).*;
}

pub fn delay(milliseconds: u32) void {
    const start = get_ticks();
    // `-%` is to wrap
    while ((get_ticks() -% start) < milliseconds) {}
}


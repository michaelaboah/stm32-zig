pub fn export_vector_table() void {
    @export(vector_table, .{
        .name = "vector_table",
        .section = ".vectors",
        .linkage = .strong,
    });
}


// For the linkerscript
extern var _stack: anyopaque;
extern var _data_loadaddr: anyopaque;
extern var _data: anyopaque;
extern var _edata: anyopaque;
extern var _ebss: anyopaque;


const InterruptHandlerFn = *const fn () callconv(.C) void; 

fn default_handler() callconv(.C) noreturn {
    while (true) {}
}

fn null_handler() callconv(.C) void {}

const reset_handler = @import("startup.zig").reset_handler;

pub const VectorTable = extern struct {
    initial_sp_value: *anyopaque, // Reserved  (0x0000 0000)
    reset: InterruptHandlerFn = reset_handler, // Reset  (0x0000 0004)
    nmi: InterruptHandlerFn = null_handler, // Non maskable interrupt. The RCC Clock Security System (CSS) is linked to the NMI vector  (0x0000 0008)
    hard_fault: InterruptHandlerFn = default_handler, // All class of fault  (0x0000_000C)
    mem_manage: InterruptHandlerFn = default_handler, // Memory management  (0x0000_0010)
    bus_fault: InterruptHandlerFn = default_handler, // Pre-fetch fault, memory access fault  (0x0000_0014)
    usage_fault: InterruptHandlerFn = default_handler, // Undefined instruction of illegal state (0x0000_0018)
    rsvp1: [4]u32 = undefined,
    sv_call: InterruptHandlerFn = default_handler, // System service call via SWI instruction (0x0000_002C)
    debug_monitor: InterruptHandlerFn = default_handler, // Debug Monitor (0x0000_0030)
    rsvp2: u32 = undefined,
    pend_sv: InterruptHandlerFn = default_handler, // Pendable request for system service (0x0000_0038)
    sys_tick: InterruptHandlerFn = @import("core/system.zig").systick_handler, // System tick timer (0x0000_003C)
    wwdg: InterruptHandlerFn = default_handler, // Window Watchdog interrupt (0x0000_0040)
    pvd: InterruptHandlerFn = default_handler, // PVD through EXTI line detection interrupt (0x0000_0044)
    tamp_stamp: InterruptHandlerFn = default_handler, // Tamper and TimeStamp interrupts through the EXTI line (0x0000_0048)
    rtc_wkup: InterruptHandlerFn = default_handler, // RTC Wakeup interrupt through the EXTI line (0x0000_004C)
    flash: InterruptHandlerFn = default_handler, // Flash Global interrupt (0x0000_0050)
    rcc: InterruptHandlerFn = default_handler, // RCC Global interrupt (0x0000_0054)
    extl0: InterruptHandlerFn = default_handler, // EXTL Line0 interrupt (0x0000_0058)
    extl1: InterruptHandlerFn = default_handler, // EXTL Line1 interrupt (0x000_005C)
    extl2: InterruptHandlerFn = default_handler, // EXTL Line2 interrupt (0x0000_0060)
    extl3: InterruptHandlerFn = default_handler, // EXTL Line3 interrupt (0x0000_0064)
    extl4: InterruptHandlerFn = default_handler, // EXTL Line4 interrupt (0x0000_0068)
    dma1_stream0: InterruptHandlerFn = default_handler, // DMA1 Stream0 global interrupt (0x0000_006C)
    dma1_stream1: InterruptHandlerFn = default_handler, // DMA1 Stream1 global interrupt (0x0000_0070)
    dma1_stream2: InterruptHandlerFn = default_handler, // DMA1 Stream2 global interrupt (0x0000_0074)
    dma1_stream3: InterruptHandlerFn = default_handler, // DMA1 Stream3 global interrupt (0x0000_0078)
    dma1_stream4: InterruptHandlerFn = default_handler, // DMA1 Stream4 global interrupt (0x0000_007C)
    dma1_stream5: InterruptHandlerFn = default_handler, // DMA1 Stream5 global interrupt (0x0000_0080)
    dma1_stream6: InterruptHandlerFn = default_handler, // DMA1 Stream6 global interrupt (0x0000_0084)
    adc: InterruptHandlerFn = default_handler, // ADC1, ADC2, ADC3 global interrupts (0x0000_0088)
    can1_tx: InterruptHandlerFn = default_handler, // CAN1 TX interrupt (0x0000_008C)
    can1_rx0: InterruptHandlerFn = default_handler, // CAN1 RX0 interrupts (0x0000_0090)
    can1_rx1: InterruptHandlerFn = default_handler, // CAN1 RX1 interrupts (0x0000_0094)
    can1_sce: InterruptHandlerFn = default_handler, // CAN1 SCE interrupt (0x0000_0098)
    exitl9_5: InterruptHandlerFn = default_handler, // EXTL Line [9:5] interrupts (0x0000_009C)
    tim1_brk_tim9: InterruptHandlerFn = default_handler, // TIM1 Break interrupt and TIM9 global interrupt (0x0000_00A0)
    tim1_up_tim10: InterruptHandlerFn = default_handler, // TIM1 Update interrupt and TIM10 global interrupt (0x0000_00A4)
    tim1_trg_com_tim11: InterruptHandlerFn = default_handler, // TIM1 Trigger and Communication interrupts and TIM11 global interrupt (0x0000_00A8)
    tim1_cc: InterruptHandlerFn = default_handler, // TIM1 Capture Compare interrupt (0x0000_00AC)
    tim2: InterruptHandlerFn = default_handler, // TIM1 global interrupt (0x0000_00B0)
    tim3: InterruptHandlerFn = default_handler, // TIM2 global interrupt (0x0000_00B4)
    tim4: InterruptHandlerFn = default_handler, // TIM3 global interrupt (0x0000_00B8)
    i2c1_ev: InterruptHandlerFn = default_handler, // I^2C1 event interrupt (0x0000_00BC)
    i2c1_er: InterruptHandlerFn = default_handler, // I^2C1 error interrupt (0x0000_00C0)
    i2c2_ev: InterruptHandlerFn = default_handler, // I^2C2 event interrupt (0x0000_00C4)
    i2c2_er: InterruptHandlerFn = default_handler, // I^2C2 error interrupt (0x0000_00C8)
    spi1: InterruptHandlerFn = default_handler, // SPI1 global interrupt (0x0000_00CC)
    spi2: InterruptHandlerFn = default_handler, // SPI2 global interrupt (0x0000_00D0)
    usart1: InterruptHandlerFn = default_handler, // USART1 global interrupt (0x0000_00D4)
    usart2: InterruptHandlerFn = default_handler, // USART2 global interrupt (0x0000_00D8)
    usart3: InterruptHandlerFn = default_handler, // USART3 global interrupt (0x0000_00DC)
    extil15_10: InterruptHandlerFn = default_handler, // EXTI Line[15:10] interrupts (0x0000_00E0)
    rtc_alarm: InterruptHandlerFn = default_handler, // RTC Alarms (A and B) through EXTI line interrupt (0x0000_00E4)
    otg_fs_wkup: InterruptHandlerFn = default_handler, // USB On-The-Go FS Wakeup through EXTI line interrupt (0x0000_00E8)
    tim8_brk_tim12: InterruptHandlerFn = default_handler, // TIM8 Break interrupt and TIM12 global interrupt (0x0000_00EC)
    tim8_up_tim13: InterruptHandlerFn = default_handler, // TIM8 Update interrupt and TIM13 global interrupt (0x0000_00F0)
    tim8_trg_com_tim14: InterruptHandlerFn = default_handler, // TIM8 Trigger and Communication interrupts and TIM14 global interrupt (0x0000_00F4)
    tim8_cc: InterruptHandlerFn = default_handler, // TIM8 Capture Compare interrupt (0x0000_00F8)
    dma1_stream7: InterruptHandlerFn = default_handler, // DMA1 Stream7 global interrupt (0x0000_00FC)
    fsmc: InterruptHandlerFn = default_handler, // FSMC global interrupt (0x0000_0100)
    sdio: InterruptHandlerFn = default_handler, // SDIO global interrupt (0x0000_0104)
    tim5: InterruptHandlerFn = default_handler, // TIM5 global interrupt (0x0000_0108)
    spi3: InterruptHandlerFn = default_handler, // SPI3 global interrupt (0x0000_010C)
    usart4: InterruptHandlerFn = default_handler, // USART4 global interrupt (0x0000_0110)
    usart5: InterruptHandlerFn = default_handler, // USART5 global interrupt (0x0000_0114)
    tim6_dac: InterruptHandlerFn = default_handler, // TIM6 global interrupt, DAC1 and DAC2 underrun error interrupts (0x0000_0118)
    tim7: InterruptHandlerFn = default_handler, // TIM7 global interrupt (0x0000_011C)
    dma2_stream0: InterruptHandlerFn = default_handler, // DMA2 Stream0 global interrupt (0x0000_0120)
    dma2_stream1: InterruptHandlerFn = default_handler, // DMA2 Stream1 global interrupt (0x0000_0124)
    dma2_stream2: InterruptHandlerFn = default_handler, // DMA2 Stream2 global interrupt (0x0000_0128)
    dma2_stream3: InterruptHandlerFn = default_handler, // DMA2 Stream3 global interrupt (0x0000_012C)
    dma2_stream4: InterruptHandlerFn = default_handler, // DMA2 Stream4 global interrupt (0x0000_0130)
    eth: InterruptHandlerFn = default_handler, // Ethernet global interrupt (0x0000_0134)
    eth_wkup: InterruptHandlerFn = default_handler, // Ethernet Wakeup through EXTI line interrupt (0x0000_0138)
    can2_tx: InterruptHandlerFn = default_handler, // CAN2 TX interrupts (0x0000_013C)
    can2_rx0: InterruptHandlerFn = default_handler, // CAN2 RX0 interrupts (0x0000_0140)
    can2_rx1: InterruptHandlerFn = default_handler, // CAN2 RX1 interrupt (0x0000_0144)
    can2_sce: InterruptHandlerFn = default_handler, // CAN2 SCE interrupt (0x0000_0148)
    otg_fs: InterruptHandlerFn = default_handler, // USB On the Go FS global interrupt (0x0000_014C)
    dma2_stream5: InterruptHandlerFn = default_handler, // DMA2 Stream5 global interrupt (0x0000_0150)
    dma2_stream6: InterruptHandlerFn = default_handler, // DMA2 Stream6 global interrupt (0x0000_0154)
    dma2_stream7: InterruptHandlerFn = default_handler, // DMA2 Stream7 global interrupt (0x0000_0158)
    usart6: InterruptHandlerFn = default_handler, // USART6 global interrupt (0x0000_015C)
    i2c3_ev: InterruptHandlerFn = default_handler, // I^2C3 event interrupt (0x0000_0160)
    i2c3_er: InterruptHandlerFn = default_handler, // I^2C3 error interrupt (0x0000_0164)
    otg_hs_epi_out: InterruptHandlerFn = default_handler, // USB On-The-Go HS End Point 1 out interrupt (0x0000_0168)
    otg_hs_epi_in: InterruptHandlerFn = default_handler, // USB On-The-Go HS End Point 1 in interrupt (0x0000_016C)
    otg_hs_wkup: InterruptHandlerFn = default_handler, // USB On-The-Go HS Wakeup through EXTI line interrupt (0x0000_0170)
    otg_hs: InterruptHandlerFn = default_handler, // USB On-The-Go HS Wakeup global interrupt (0x0000_0174)
    dcmi: InterruptHandlerFn = default_handler, // DCMI global interrupt (0x0000_0178)
    cryp: InterruptHandlerFn = default_handler, // CRYP crypto global interrupt (0x0000_017C)
    hash_rng: InterruptHandlerFn = default_handler, // HASH and Rng global interrupt (0x0000_0180)
    fpu: InterruptHandlerFn = default_handler, // FPU global interrupt (0x0000_0184)
};

pub var vector_table: VectorTable = .{ .initial_sp_value = &_stack, .reset = reset_handler, };

const map = @import("shared").MAP;
const gpio = @import("shared").GPIO;
const rcc = @import("shared").RCC;
const usart = @import("shared").COMM.USART;

const FREQ: u32 = 16_000_000;

const Usart2: *volatile usart.Usart = @ptrFromInt(map.USART2);
const Rcc: *volatile rcc.RCC = @ptrFromInt(map.RCC_BASE);
const GpioA: *volatile gpio.Port  = @ptrFromInt(map.GPIOA_BASE + 0x00);  


pub fn setup() void {
    // Alternate Function
    const af: u8 = 7;
    const tx_pin: u32 = map.GPIOA_BASE | 2;
    const rx_pin: u32 = map.GPIOA_BASE | 3;



    // Turn on respective USART2 bus registers
    Rcc.APB1ENR |= (1 << 17);

    GpioA.set_mode(@intCast(tx_pin), gpio.MODE.AF);
    GpioA.set_af(@intCast(tx_pin), af);
    GpioA.set_mode(@intCast(rx_pin), gpio.MODE.AF);
    GpioA.set_af(rx_pin, af);

    // Disable
    Usart2.CR1 = 0;

    Usart2.BRR = FREQ / 115200;

    // Enable
    Usart2.CR1 |= usart.CR1.UE | usart.CR1.TE | usart.CR1.RE;

}

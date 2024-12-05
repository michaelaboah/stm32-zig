pub const PERIPH_BASE: u32 = 0x4000_0000;
/// Advanced Peripheral Bus 1
/// Address: 0x4000_0000
pub const APB1: u32 = PERIPH_BASE;
/// Advanced Peripheral Bus 2
/// Address: 0x4001_0000
pub const APB2: u32 = PERIPH_BASE + 0x1_0000;
/// Advanced High Peripheral Bus 1
/// Address: 0x4002_0000
pub const AHB1: u32 = PERIPH_BASE + 0x2_0000;
/// Advanced High Peripheral Bus 2
/// Address: 0x5000_0000
pub const AHB2: u32 = PERIPH_BASE + 0x1000_0000;
/// Advanced High Peripheral Bus 3
/// Address: 0x6000_0000
pub const AHB3: u32 = PERIPH_BASE + 0x2000_0000;


// RCC Branch

/// Reset Clock Control Base
/// Address: 0x4002_3800
pub const RCC_BASE: u32 = AHB1 + 0x3800;
/// RCC clock control register
/// Address: 0x4002_3800
pub const RCC_CR: u32 = RCC_BASE + 0x00;
/// RCC Reset Register
/// Address: 0x4002_3810
pub const RCC_AHB1_RSTR: u32 = RCC_BASE + 0x10;
/// RCC Reset Register
/// Address: 0x4002_3814
pub const RCC_AHB2_RSTR: u32 = RCC_BASE + 0x14;
/// RCC Reset Register
/// Address: 0x4002_3814
pub const RCC_AHB3_RSTR: u32 = RCC_BASE + 0x18;
/// RCC Reset Register
/// Address: 0x4002_3820
pub const RCC_APB1_RSTR: u32 = RCC_BASE + 0x20;
/// RCC Reset Register
/// Address: 0x4002_3824
pub const RCC_APB2_RSTR: u32 = RCC_BASE + 0x24;
/// RCC Enable Register
/// Address: 0x4002_3830
pub const RCC_AHB1_ENR: u32 = RCC_BASE + 0x30;
/// RCC Enable Register
/// Address: 0x4002_3834
pub const RCC_AHB2_ENR: u32 = RCC_BASE + 0x34;
/// RCC Enable Register
/// Address: 0x4002_3838
pub const RCC_APB3_ENR: u32 = RCC_BASE + 0x38;
/// RCC Enable Register
/// Address: 0x4002_3840
pub const RCC_APB1_ENR: u32 = RCC_BASE + 0x40;
/// RCC Enable Register
/// Address: 0x4002_3844
pub const RCC_APB2_ENR: u32 = RCC_BASE + 0x44;

// GPIO

/// General Purpose I/O A Base
/// Address: 0x4002_0000
pub const GPIOA_BASE: u32 = AHB1 + 0x0000;
/// General Purpose I/O B Base
/// Address: 0x4002_0400
pub const GPIOB_BASE: u32 = AHB1 + 0x0400;
/// General Purpose I/O C Base
/// Address: 0x4002_0800
pub const GPIOC_BASE: u32 = AHB1 + 0x0800;
/// General Purpose I/O D Base
/// Address: 0x4002_0C00
pub const GPIOD_BASE: u32 = AHB1 + 0x0C00;
/// General Purpose I/O E Base
/// Address: 0x4002_1000
pub const GPIOE_BASE: u32 = AHB1 + 0x1000;
/// General Purpose I/O F Base
/// Address: 0x4002_1400
pub const GPIOF_BASE: u32 = AHB1 + 0x1400;
/// General Purpose I/O G Base
/// Address: 0x4002_1800
pub const GPIOG_BASE: u32 = AHB1 + 0x1800;
/// General Purpose I/O H Base
/// Address: 0x4002_1C00
pub const GPIOH_BASE: u32 = AHB1 + 0x1C00;

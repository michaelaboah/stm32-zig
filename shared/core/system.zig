pub const Systick = struct {
    /// SysTick Control and Status Register
    /// Offset: 0x00
    CSR: u32, 
    /// SysTick Reload Value Register
    /// Offset: 0x04
    RVR: u32, 
    /// SysTick Current Value Register
    /// Offset: 0x08
    CVR: u32, 
    /// SysTick Calibration Register
    /// Offset: 0x0C
    CR: u32, 
};

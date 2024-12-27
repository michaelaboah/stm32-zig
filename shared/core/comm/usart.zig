pub const Usart = struct {
    const Self = @This();
    /// Status Register
    /// Offset: 0x00
    SR: u32,
    /// Data Register
    /// Offset: 0x04
    DR: u32,
    /// Baud Rate Register
    /// Offset: 0x08
    BRR: u32,
    /// Control 1 Register | usart.CR1 for settings
    /// Offset: 0x0C
    CR1: u32,
    /// Control 2 Register
    /// Offset: 0x10
    CR2: u32,
    /// Control 3 Register
    /// Offset: 0x14
    CR3: u32,
    /// Guard Time & Prescaler Register
    /// Offset: 0x18
    GTPR: u32,

    pub inline fn read_ready(self: Self) bool {
        const RXNE: u32 = (1 << 5); // Read Data Register Not Empty
                                    // 0: Data is not received | 1: Received data is read to be read
        if ((self.SR & RXNE) == 1) {
            return true;
        } else {
            return false;
        }
    }

    pub inline fn read_byte(self: Self) u8 {
       return (self.DR & 255); 
    }

    pub inline fn write_byte(self: *volatile Self, byte: u8) void {
        self.DR = byte;
        const TXE: u32 = (1 << 7); // Transmit Data Register Empty
                                   // 0: Data not transferd | 1: Data is transfered
        // Wait for transmission to end when TXE == 1
        while (self.SR & TXE == 0) asm volatile ("nop");
    }

    pub inline fn write_buffer(self: *volatile Self, buffer: []const u8) void {
        for (buffer) |byte| {
            self.write_byte(byte);
        }
    }
};

/// Control Register Settings
pub const CR1 = enum {
    /// Oversampling mode 
    pub const OVER8: u32 = (1 << 15);
    /// Usart Enable
    pub const UE: u32 = (1 << 13);
    /// Word length
    pub const M: u32 = (1 << 12);
    /// Wakeup method
    pub const WAKE: u32 = (1 << 11);
    /// Parity Control Enable
    pub const PCE: u32 = (1 << 10);
    /// Parity Selection
    pub const PS: u32 = (1 << 9);
    /// PEIE Interrupt Enable
    pub const PEIE: u32 = (1 << 8);
    /// TXE Interrupt Enable
    pub const TXEIE: u32 = (1 << 7);
    /// Transmisson Complete Interrupt Enable
    pub const TCIE: u32 = (1 << 6);
    /// RXNE Interrupt Enable
    pub const RXNEIE: u32 = (1 << 5);
    /// Idle Interrupt Enable
    pub const IDLEIE: u32 = (1 << 4);
    /// Transmitter Enable
    pub const TE: u32 = (1 << 3);
    /// Receiver Enable
    pub const RE: u32 = (1 << 2);
    /// Receiver Wakeup
    pub const RWU: u32 = (1 << 1);
    
    /// Send Break
    pub const SBK: u32 = (1 << 0);
};

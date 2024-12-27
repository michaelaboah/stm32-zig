# stm32-zig

A **bare-metal firmware project** for STM32 microcontrollers written in **Zig**, inspired by the educational approaches of [lowbyteproductions/bare-metal-series](https://github.com/lowbyteproductions/bare-metal-series) and [cpq/bare-metal-programming-guide](https://github.com/cpq/bare-metal-programming-guide). This project demonstrates lightweight and efficient firmware development without relying on external frameworks or vendor-specific HALs.

## Goals
- **Bare-metal programming**: Direct interaction with STM32 hardware using Zig.
- **Minimal dependencies**: Focus on understanding low-level microcontroller programming.
- **Write firmware and device drivers**: First start with STM32F4 with USART, IC2, and SPI then move to RP for BT, WiFi, ETH, potentially (HDMI)
- **Simple RTOS**: Split CPU cycles into threads/tasks and manage functions plus shared resources if necessary (Raw Concurrency)
- **Minimal Abstractions**: Stay close to the hardware and keep abstraction surface area smal and portable
- **Learn to Debug**: GDB/LLDB or other methods to inspect problems

## Prerequisites
- STM32 development board (tested with STM32F4, adaptable to other series).
- ARM GCC/LLVM toolchain or equivalent for flashing/debugging.

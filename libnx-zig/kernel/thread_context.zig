/// Armv8 CPU register.
pub const CpuRegister = extern union {
    x: u64,  //< 64-bit AArch64 register view.
    w: u32,  //< 32-bit AArch64 register view.
    r: u32  //< AArch32 register view.
};

/// Armv8 NEON register.
pub const FpuRegister = extern union {
    v: u128,  //< 128-bit vector view.
    d: f64,   //< 64-bit double-precision view.
    s: f32,   //< 32-bit single-precision view.
};

/// Thread context structure (register dump)
pub const ThreadContext = extern struct {
    cpu_gprs: [29]CpuRegister, //< GPRs 0..28. Note: also contains AArch32 SPRs.
    fp: u64,                   //< Frame pointer (x29) (AArch64). For AArch32, check r11.
    lr: u64,                   //< Link register (x30) (AArch64). For AArch32, check r14.
    sp: u64,                   //< Stack pointer (AArch64). For AArch32, check r13. 
    pc: CpuRegister,           //< Program counter.
    psr: u32,                  //< PSTATE or cpsr.
    fpu_gprs: [32]FpuRegister, //< 32 general-purpose NEON registers.
    fpcr: u32,                 //< Floating-point control register.
    fpsr: u32,                 //< Floating-point status register.
    tpidr: u64                 //< EL0 Read/Write Software Thread ID Register.
};
//! Zig port of libnx's `switch/arm/thread_context.h` ("AArch64 register dump format and related definitions.").
//! Original author(s): TuxSH.
//! Copyright (c) 2017-2018 libnx Authors. Licensed under the ISC License
//! (switchbrew/libnx) -- see /LICENSE-libnx.md at the repo root.

pub const BIT = @import("../types.zig").BIT;

pub const RegisterGroup = enum(u32) {
    RegisterGroup_CpuGprs = BIT(0),    //< General-purpose CPU registers (x0..x28 or r0..r10,r12).
    RegisterGroup_CpuSprs = BIT(1),    //< Special-purpose CPU registers (fp, lr, sp, pc, PSTATE or cpsr, TPIDR_EL0).
    RegisterGroup_FpuGprs = BIT(2),    //< General-purpose NEON registers.
    RegisterGroup_FpuSprs = BIT(3),    //< Special-purpose NEON registers.

    RegisterGroup_CpuAll  = .RegisterGroup_CpuGprs | .RegisterGroup_CpuSprs, //< All CPU registers.
    RegisterGroup_FpuAll  = .RegisterGroup_FpuGprs | .RegisterGroup_FpuSprs, //< All NEON registers.
    RegisterGroup_All     = .RegisterGroup_CpuAll  | .RegisterGroup_FpuAll,  //< All registers.
};

pub const ThreadExceptionDesc = enum(u32) {
    ThreadExceptionDesc_InstructionAbort = 0x100,   //< Instruction abort
    ThreadExceptionDesc_MisalignedPC     = 0x102,   //< Misaligned PC
    ThreadExceptionDesc_MisalignedSP     = 0x103,   //< Misaligned SP
    ThreadExceptionDesc_SError           = 0x106,   //< SError [not in 1.0.0?]
    ThreadExceptionDesc_BadSVC           = 0x301,   //< Bad SVC
    ThreadExceptionDesc_Trap             = 0x104,   //< Uncategorized, CP15RTTrap, CP15RRTTrap, CP14RTTrap, CP14RRTTrap, IllegalState, SystemRegisterTrap
    ThreadExceptionDesc_Other            = 0x101,   //< None of the above, EC <= 0x34 and not a breakpoint
};

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

pub const ThreadExceptionDump = extern struct {
    error_desc:   u32,                  //< See \ref ThreadExceptionDesc.
    pad:          [3]u32,
    gpu_gprs:     [29]CpuRegister,      //< GPRs 0..28. Note: also contains AArch32 registers.
    fp:           CpuRegister,          //< Frame pointer.
    lr:           CpuRegister,          //< Link register.
    sp:           CpuRegister,          //< Stack pointer.
    pc:           CpuRegister,          //< Program counter (elr_el1).
    padding:      u64,
    fpu_gprs:     [32]FpuRegister,      //< 32 general-purpose NEON registers.
    pstate:       u32,                  //< pstate & 0xFF0FFE20
    afsr0:        u32,
    afsr1:        u32,
    esr:          u32,
    far:          CpuRegister           //< Fault Address Register.
};

pub const ThreadExceptionFrameA64 = extern struct {
    cpu_gprs:     [9]u64,      //< GPRs 0..8.
    lr:           u64,
    sp:           u64,
    elr_el1:      u64,
    pstate:       u32,      //< pstate & 0xFF0FFE20
    afsr0:        u32,
    afsr1:        u32,
    esr:          u32,
    far:          u64
};

pub const ThreadExceptionFrameA32 = extern struct {
    gpu_gprs:     [8]u32,       //< GPRs 0..7.
    sp:            u32,
    lr:            u32,
    elr_el1:       u32,
    tpidr_el0:     u32,         //< tpidr_el0 = 1
    cpsr:          u32,         //< cpsr & 0xFF0FFE20
    afsr0:         u32,
    afsr1:         u32,
    esr:           u32,
    far:           u32
};

pub inline fn threadContextIsAArch64(ctx: *const ThreadContext) bool {
    return (ctx.psr & 0x10) == 0;
}

pub inline fn threadExceptionIsAArch64(ctx: *const ThreadContext) bool {
    return (ctx.pstate & 0x10) == 0;
}
const __wait = @import("wait.zig");
const __types = @import("types.zig");
const ThreadFunc = __types.ThreadFunc;
const Handle = __types.Handle;
// ==== thread_context.h ====

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
// ==========================

pub const Thread = extern struct {
    const Self = @This();

    handle: Handle,                //< Thread handle.
    owns_stack_mem: bool,       //< Whether the stack memory is automatically allocated.
    stack_mem: *anyopaque,      //< Pointer to stack memory.
    stack_mirror: *anyopaque,   //< Pointer to stack memory mirror.
    stack_size: u64,            //< Stack size.
    tls_array: **anyopaque,
    next: *Self,
    prev_next: *Self,
};

pub inline fn waiterForThread(t: *Thread) __wait.Waiter {
    return __wait.waiterForHandle(t.handle);
}

pub extern fn threadCreate(t: *Thread, entry: ThreadFunc, arg: *anyopaque, stack_mem: *anyopaque, stack_size: u64, prio: i32, cpuid: i32) __types.Result;
pub extern fn threadStart(t: *Thread) __types.Result;
pub extern fn threadExit() noreturn;
pub extern fn threadWaitForExit(t: *Thread) __types.Result;
pub extern fn threadClose(t: *Thread) __types.Result;
pub extern fn threadPause(t: *Thread) __types.Result;
pub extern fn threadResume(t: *Thread) __types.Result;
pub extern fn threadDumpContext(ctx: *ThreadContext, t: *Thread) __types.Result;
pub extern fn threadGetSelf() *Thread;
pub extern fn threadGetCurHandle() Handle;

const __destructor = *fn(*anyopaque) void;
pub extern fn threadTlsAlloc(destructor: __destructor) i32;

pub extern fn threadTlsGet(slot_id: i32) *anyopaque;
pub extern fn threadTlsSet(slot_id: i32, value: *anyopaque) void;
pub extern fn threadTlsFree(slot_id: i32) void;
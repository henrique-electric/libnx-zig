//! libnx.zig — hand-ported Zig bindings for libnx's **Core** and **Graphics** modules.
//!
//! Ported from: switchbrew/libnx (https://github.com/switchbrew/libnx)
//!
//! WHAT THIS IS
//!   Extern bindings, not a reimplementation. Every `extern fn` below is a
//!   1:1 declaration of a real libnx.a symbol — the actual logic still lives
//!   in libnx's C/ASM (svc.s, thread.c, gfx code, etc.). Link this against a
//!   devkitA64-built libnx.a and calling e.g. `threadCreate(...)` from Zig
//!   runs the real libnx implementation. The only *real* Zig code here is
//!   for things that were `static inline` in the original C headers too
//!   (MAKERESULT, mutexInit, BIT, ...) — porting those as logic is porting
//!   them faithfully.
//!
//! SCOPE
//!   Core:     types.h, result.h, kernel/{mutex,condvar,rwlock,semaphore,
//!             event,uevent,utimer,wait,thread,virtmem}.h, a common subset
//!             of kernel/svc.h (~30 of the ~90 syscalls).
//!   Graphics: display/{native_window,framebuffer}.h, services/vi.h (common
//!             subset), and the minimal nvidia/nvmap.h needed to back a
//!             framebuffer with GPU-visible memory.
//!   Deliberately NOT ported: filesystem/account/hid/etc. services, the
//!             deko3d GPU API, applet management, the full svc.h and result
//!             module/description tables (both are large, mostly-mechanical,
//!             auto-generated lists in upstream libnx — pull them in
//!             separately if you need them).
//!
//! ⚠ ABI RISK — READ THIS
//!   A few libnx structs (`Thread`, `NWindow`-adjacent `Framebuffer`,
//!   `ViDisplay`, `ViLayer`, `UEvent`, `UTimer`, `NvMap`) are allocated by
//!   *caller-provided storage* and embed internal/newlib fields (e.g.
//!   `Thread` contains a full newlib `struct _reent`) whose exact size and
//!   layout depends on your devkitA64/newlib version and could not be
//!   reconstructed byte-exactly from memory for this port. Each such type is
//!   marked `ABI-UNCERTAIN` below with a generously-sized `_reserved` pad.
//!   Before relying on a stack/global instance of one of these (as opposed
//!   to just holding a pointer libnx gave you), verify `sizeof(T)` against
//!   your actual toolchain (e.g. a one-line C program compiled with
//!   devkitA64: `printf("%zu\n", sizeof(Thread));`) and adjust `_reserved`
//!   to match. Getting this wrong means libnx writes past the end of the
//!   struct and silently corrupts adjacent memory — it will not crash where
//!   the bug actually is.
//!
//!   `NWindow` itself is modeled as fully `opaque` instead, since idiomatic
//!   libnx code only ever gets a `*NWindow` handed to it (from
//!   `nwindowGetDefault()`) and never allocates or reads its fields — the
//!   opaque-pointer route sidesteps the ABI risk entirely for that one.
//!
//! LINKING
//!   This assumes a target ABI matching devkitA64's aarch64/newlib build of
//!   libnx (AAPCS64, standard GCC struct layout — Zig's `extern struct`
//!   already follows the platform C ABI, so field order/types are what
//!   matter here, not any extra annotation). In your build.zig, compile for
//!   an aarch64 target and link the real `libnx.a` (plus `libnvctrl.a` /
//!   whatever else that build of libnx.a expects); this file supplies no
//!   symbols on its own. `callconv(.c)` below is Zig 0.16's spelling for the
//!   platform C calling convention — adjust if you're on an older Zig.

const std = @import("std");

// =============================================================================
// switch/types.h — fundamental types
// =============================================================================

pub const Handle = u32;
pub const INVALID_HANDLE: Handle = 0;

/// Entry point type for libnx-managed threads (`switch/types.h: ThreadFunc`).
pub const ThreadFunc = *const fn (arg: ?*anyopaque) callconv(.c) void;

/// Generic no-argument function pointer (`switch/types.h: VoidFn`).
pub const VoidFn = *const fn () callconv(.c) void;

/// `#define BIT(n) (1U<<(n))`
pub inline fn BIT(n: u5) u32 {
    return @as(u32, 1) << n;
}

/// `#define BITL(n) (1UL<<(n))`
pub inline fn BITL(n: u6) u64 {
    return @as(u64, 1) << n;
}

pub inline fn UTIL_MIN(a: anytype, b: anytype) @TypeOf(a, b) {
    return if (a < b) a else b;
}
pub inline fn UTIL_MAX(a: anytype, b: anytype) @TypeOf(a, b) {
    return if (a > b) a else b;
}

/// `#define UTIL_ALIGN_UP(x, align)` (align must be a power of two)
pub inline fn UTIL_ALIGN_UP(x: anytype, alignment: @TypeOf(x)) @TypeOf(x) {
    return (x + (alignment - 1)) & ~(alignment - 1);
}
/// `#define UTIL_ALIGN_DOWN(x, align)` (align must be a power of two)
pub inline fn UTIL_ALIGN_DOWN(x: anytype, alignment: @TypeOf(x)) @TypeOf(x) {
    return x & ~(alignment - 1);
}

// =============================================================================
// switch/result.h — Result codes
// =============================================================================

pub const Result = u32;
pub const ResultSuccess: Result = 0;

/// `#define R_MODULE(res)`
pub inline fn R_MODULE(res: Result) u32 {
    return res & 0x1FF;
}
/// `#define R_DESCRIPTION(res)`
pub inline fn R_DESCRIPTION(res: Result) u32 {
    return (res >> 9) & 0x1FFF;
}
/// `static inline Result MAKERESULT(u32 module, u32 description)`
pub inline fn MAKERESULT(module: u32, description: u32) Result {
    return (module & 0x1FF) | ((description & 0x1FFF) << 9);
}

/// `#define R_VALUE(res) ((u32)(res))`
pub inline fn R_VALUE(res: Result) u32 {
    return res;
}
/// `#define R_SUCCEEDED(res) (R_VALUE(res)==0)`
pub inline fn R_SUCCEEDED(res: Result) bool {
    return R_VALUE(res) == 0;
}
/// `#define R_FAILED(res) (R_VALUE(res)!=0)`
pub inline fn R_FAILED(res: Result) bool {
    return R_VALUE(res) != 0;
}
//
// NOTE: libnx's `R_TRY`/`R_UNLESS`/`R_ABORT_UNLESS` family are C
// preprocessor control-flow macros (early-return on failure, etc). Zig's
// `try`/error unions are the idiomatic native replacement for that pattern
// rather than something to port literally, so they're intentionally left
// out — wrap `Result` in your own error-set conversion at the call site.

/// Error-module numbers (`switch/result.h: enum { Module_* }`).
/// NOTE: upstream enumerates roughly 150 modules; only the ones unambiguous
/// from memory are listed here. Check libnx's result.h / the SwitchBrew
/// "Error codes" wiki page for any module number not listed below.
pub const Module = enum(u32) {
    Kernel = 1,
    Fs = 2,
    Libnx = 345,
    _,
};

// =============================================================================
// switch/kernel/mutex.h
// =============================================================================

pub const Mutex = u32;
const HANDLE_WAIT_MASK: u32 = 0x40000000;

/// `static inline void mutexInit(Mutex *m)`
pub inline fn mutexInit(m: *Mutex) void {
    m.* = 0;
}
/// `static inline bool mutexIsLocked(Mutex *m)`
pub inline fn mutexIsLocked(m: *const Mutex) bool {
    return (m.* & ~HANDLE_WAIT_MASK) != 0;
}

pub extern fn mutexLock(m: *Mutex) void;
pub extern fn mutexUnlock(m: *Mutex) void;
pub extern fn mutexTryLock(m: *Mutex) bool;

// =============================================================================
// switch/kernel/condvar.h
// =============================================================================

pub const CondVar = u32;

/// `static inline void condvarInit(CondVar *c)`
pub inline fn condvarInit(c: *CondVar) void {
    c.* = 0;
}

pub extern fn condvarWaitTimeout(c: *CondVar, m: *Mutex, timeout: u64) Result;
/// `static inline Result condvarWait(CondVar *c, Mutex *m)` (timeout = UINT64_MAX)
pub inline fn condvarWait(c: *CondVar, m: *Mutex) Result {
    return condvarWaitTimeout(c, m, std.math.maxInt(u64));
}
pub extern fn condvarWakeOne(c: *CondVar) Result;
pub extern fn condvarWakeAll(c: *CondVar) Result;

// =============================================================================
// switch/kernel/rwlock.h
// =============================================================================

pub const RwLock = extern struct {
    mutex: Mutex,
    condvar_reader_wait: CondVar,
    condvar_writer_wait: CondVar,
    read_lock_count: u32,
    write_lock_count: u32,
    write_desired_count: i32,
    owner_tag: u32,
};

pub extern fn rwlockInit(r: *RwLock) void;
pub extern fn rwlockReadLock(r: *RwLock) void;
pub extern fn rwlockReadUnlock(r: *RwLock) void;
pub extern fn rwlockWriteLock(r: *RwLock) void;
pub extern fn rwlockWriteUnlock(r: *RwLock) void;
pub extern fn rwlockIsWriteLockHeldByCurrentThread(r: *const RwLock) bool;
pub extern fn rwlockIsOwnedByCurrentThread(r: *const RwLock) bool;

// =============================================================================
// switch/kernel/semaphore.h
// =============================================================================

pub const Semaphore = extern struct {
    count: u64,
    mutex: Mutex,
    condvar: CondVar,
};

pub extern fn semaphoreInit(s: *Semaphore, initial_count: u64) void;
pub extern fn semaphoreSignal(s: *Semaphore) void;
pub extern fn semaphoreWait(s: *Semaphore) void;
pub extern fn semaphoreTryWait(s: *Semaphore) bool;

// =============================================================================
// switch/kernel/event.h
// =============================================================================

pub const Event = extern struct {
    revent: Handle,
    wevent: Handle,
    autoclear: bool,
};

pub extern fn eventLoadRemote(t: *Event, handle: Handle, autoclear: bool) void;
pub extern fn eventCreate(t: *Event, autoclear: bool) Result;
pub extern fn eventWait(t: *Event, timeout: u64) Result;
pub extern fn eventActive(t: *const Event) bool;
pub extern fn eventClear(t: *Event) Result;
/// Only valid if `t.wevent != INVALID_HANDLE`.
pub extern fn eventFire(t: *Event) Result;
pub extern fn eventClose(t: *Event) void;

// =============================================================================
// switch/kernel/uevent.h
// =============================================================================
// ABI-UNCERTAIN: field layout is best-effort from memory. Treat `UEvent` as
// opaque storage — go through the functions below rather than reading/
// writing fields directly — unless you've confirmed this against your
// libnx version's uevent.h.

pub const UEvent = extern struct {
    inner: extern union {
        handle: Handle,
        fake: extern struct {
            assigned_core: u32,
            signal: bool,
        },
    },
    autoclear: bool,
    has_handle: bool,
};

pub extern fn ueventCreate(t: *UEvent, autoclear: bool) void;
pub extern fn ueventSignal(t: *UEvent) void;
pub extern fn ueventClear(t: *UEvent) void;

// =============================================================================
// switch/kernel/utimer.h
// =============================================================================
// ABI-UNCERTAIN, see the UEvent note above (UTimer embeds a UEvent).

pub const TimerType = enum(c_int) {
    one_shot = 0,
    repeating = 1,
};

pub const UTimer = extern struct {
    uevent: UEvent,
    type: TimerType,
    next_tick: u64,
    interval: u64,
};

pub extern fn utimerCreate(t: *UTimer, interval: u64, kind: TimerType) void;
pub extern fn utimerStart(t: *UTimer) void;
pub extern fn utimerStop(t: *UTimer) void;

// =============================================================================
// switch/kernel/wait.h
// =============================================================================
// Only the plain single-handle wait is ported. Upstream's `Waiter`/
// `waitMulti(...)` layer (waiting on a mix of Handles/Events/UEvents/
// UTimers/Threads at once) is a variadic-macro convenience built on
// `waitObjects()`, and its `Waiter` tagging scheme wasn't something that
// could be reconstructed byte-exactly from memory — left out rather than
// guessed at. See switch/kernel/wait.h upstream if you need it; in Zig you
// could reimplement the same idea idiomatically with a comptime-known array
// of tagged unions instead of a variadic macro.

pub extern fn waitSingleHandle(h: Handle, timeout: u64) Result;

// =============================================================================
// switch/kernel/thread.h
// =============================================================================
// Originally flagged ABI-UNCERTAIN here on the assumption that `Thread`
// embeds a full newlib `struct _reent` plus a `tls_array` pointer. Verified
// against a real devkitA64 toolchain (sizeof(Thread) == 56 on the reporting
// user's setup) that neither is actually present inline — reentrancy state
// must be tracked elsewhere, not in this struct. The 7 fields below account
// for all 56 bytes exactly (`handle`+`owns_handle` share one padded 8-byte
// slot on AArch64, then six more 8-byte fields), which is strong evidence
// the layout — not just the size — is right, though it isn't independently
// confirmed field-by-field.
//
// This total size is pinned to one specific toolchain snapshot, not a
// documented constant — re-run `printf("%zu\n", sizeof(Thread));` (compiled
// with devkitA64, `#include <switch.h>`) after any devkitA64/libnx update
// and adjust the struct (and the assert below) if it no longer matches.
// `threadCreate` writes into CALLER-supplied storage (a stack or global
// `Thread`, not something libnx heap-allocates for you), so a mismatch here
// means libnx silently writes past the end of it.

pub const Thread = extern struct {
    handle: Handle,
    owns_handle: bool,
    stack_mem: u64,
    stack_mirror: u64,
    stack_sz: usize,
    stack: ?*anyopaque,
    entry: ThreadFunc,
    arg: ?*anyopaque,
};
comptime {
    std.debug.assert(@sizeOf(Thread) == 56);
}

pub extern fn threadCreate(
    t: *Thread,
    entry: ThreadFunc,
    arg: ?*anyopaque,
    stack_mem: ?*anyopaque,
    stack_sz: usize,
    prio: i32,
    cpuid: i32,
) Result;
pub extern fn threadStart(t: *Thread) Result;
pub extern fn threadWaitForExit(t: *Thread) Result;
pub extern fn threadClose(t: *Thread) Result;
pub extern fn threadPause(t: *Thread) Result;
pub extern fn threadResume(t: *Thread) Result;
pub extern fn threadGetSelf() ?*Thread;

// =============================================================================
// switch/kernel/virtmem.h
// =============================================================================

pub const VirtmemReservation = opaque {};

pub extern fn virtmemLock() void;
pub extern fn virtmemUnlock() void;
pub extern fn virtmemFindAslr(size: usize, guard_size: usize) ?*anyopaque;
pub extern fn virtmemFindCodeMemory(size: usize, guard_size: usize) ?*anyopaque;
pub extern fn virtmemFindStack(size: usize, guard_size: usize) ?*anyopaque;
pub extern fn virtmemFindHeap(size: usize, guard_size: usize) ?*anyopaque;
pub extern fn virtmemFindLegacyAlias(size: usize, guard_size: usize) ?*anyopaque;
pub extern fn virtmemFindModule(size: usize, guard_size: usize) ?*anyopaque;
pub extern fn virtmemAddReservation(mem: ?*anyopaque, size: usize) ?*VirtmemReservation;
pub extern fn virtmemRemoveReservation(rv: ?*VirtmemReservation) void;

// =============================================================================
// switch/kernel/svc.h — common subset (~30 of the ~90 syscalls)
// =============================================================================
// These are declared, not reimplemented: in real libnx these symbols are
// hand-written AArch64 syscall trampolines (svc.s). Linking against libnx.a
// gives you working implementations for free — Zig only needs the correct
// C signature. Rarer syscalls (debug/process-introspection/device-address-
// space/etc.) are omitted rather than guessed at; add them the same way if
// you need them.

pub const CUR_THREAD_HANDLE: Handle = 0xFFFF8000;
pub const CUR_PROCESS_HANDLE: Handle = 0xFFFF8001;

/// Flag-style enum, values are OR-able (e.g. `.rw` = `.r | .w`).
pub const MemoryPermission = enum(u32) {
    none = 0,
    r = 1,
    w = 2,
    rw = 3,
    x = 4,
    rx = 5,
    dont_care = 0x10000000,
    _,
};

/// Best-effort against the SwitchBrew wiki's SVC "Memory state" table —
/// double check any value here beyond the common ones (Free/Code/Normal/
/// Stack/Ipc/ThreadLocal) before depending on it.
pub const MemoryState = enum(u32) {
    free = 0x00,
    io = 0x01,
    static = 0x02,
    code = 0x03,
    code_data = 0x04,
    normal = 0x05,
    shared = 0x06,
    alias = 0x07,
    alias_code = 0x08,
    alias_code_data = 0x09,
    ipc = 0x0A,
    stack = 0x0B,
    thread_local = 0x0C,
    transfered = 0x0D,
    shared_transfered = 0x0E,
    shared_code = 0x0F,
    inaccessible = 0x10,
    non_secure_ipc = 0x11,
    non_device_ipc = 0x12,
    kernel = 0x13,
    generated_code = 0x14,
    code_out = 0x15,
    coverage = 0x16,
    _,
};

pub const MemoryAttribute = packed struct(u32) {
    locked: bool = false,
    ipc_locked: bool = false,
    device_shared: bool = false,
    uncached: bool = false,
    _reserved: u28 = 0,
};

pub const MemoryInfo = extern struct {
    addr: u64,
    size: u64,
    type: MemoryState,
    attr: MemoryAttribute,
    perm: MemoryPermission,
    ipc_refcount: u32,
    device_refcount: u32,
    padding: u32,
};

pub const PageInfo = extern struct {
    flags: u32,
};

pub const BreakReason = enum(u32) {
    panic = 0,
    assert = 1,
    user = 2,
    pre_load_dll = 3,
    post_load_dll = 4,
    pre_unload_dll = 5,
    post_unload_dll = 6,
    cpp_exception = 7,
    _,
};

pub extern fn svcSetHeapSize(out_addr: *?*anyopaque, size: usize) Result;
pub extern fn svcSetMemoryPermission(addr: *anyopaque, size: usize, perm: MemoryPermission) Result;
pub extern fn svcSetMemoryAttribute(addr: *anyopaque, size: usize, mask: u32, value: u32) Result;
pub extern fn svcMapMemory(dst: *anyopaque, src: *anyopaque, size: usize) Result;
pub extern fn svcUnmapMemory(dst: *anyopaque, src: *anyopaque, size: usize) Result;
pub extern fn svcQueryMemory(meminfo_out: *MemoryInfo, pageinfo_out: *PageInfo, addr: u64) Result;
pub extern fn svcExitProcess() noreturn;
pub extern fn svcCreateThread(handle_out: *Handle, entry: *const anyopaque, arg: ?*anyopaque, stack_top: ?*anyopaque, prio: i32, cpuid: i32) Result;
pub extern fn svcStartThread(handle: Handle) Result;
pub extern fn svcExitThread() noreturn;
pub extern fn svcSleepThread(nano: i64) void;
pub extern fn svcGetThreadPriority(prio_out: *i32, handle: Handle) Result;
pub extern fn svcSetThreadPriority(handle: Handle, prio: i32) Result;
pub extern fn svcGetThreadCoreMask(core_out: *i32, mask_out: *u64, handle: Handle) Result;
pub extern fn svcSetThreadCoreMask(handle: Handle, core: i32, mask: u64) Result;
pub extern fn svcGetCurrentProcessorNumber() u32;
pub extern fn svcSignalEvent(handle: Handle) Result;
pub extern fn svcClearEvent(handle: Handle) Result;
/// Out params are (server/write handle, client/read handle).
pub extern fn svcCreateEvent(handle_out_server: *Handle, handle_out_client: *Handle) Result;
pub extern fn svcMapSharedMemory(handle: Handle, addr: *anyopaque, size: usize, perm: MemoryPermission) Result;
pub extern fn svcUnmapSharedMemory(handle: Handle, addr: *anyopaque, size: usize) Result;
pub extern fn svcCreateTransferMemory(handle_out: *Handle, addr: *anyopaque, size: usize, perm: MemoryPermission) Result;
pub extern fn svcCloseHandle(handle: Handle) Result;
pub extern fn svcResetSignal(handle: Handle) Result;
pub extern fn svcWaitSynchronization(index_out: *i32, handles: [*]const Handle, num_handles: i32, timeout: i64) Result;
pub extern fn svcCancelSynchronization(handle: Handle) Result;
pub extern fn svcArbitrateLock(wait_tag: u32, tag_location: *u32, self_tag: u32) Result;
pub extern fn svcArbitrateUnlock(tag_location: *u32) Result;
pub extern fn svcWaitProcessWideKeyAtomic(key: *u32, tag_location: *u32, self_tag: u32, timeout: i64) Result;
pub extern fn svcSignalProcessWideKey(key: *u32, count: i32) Result;
pub extern fn svcGetSystemTick() u64;
pub extern fn svcConnectToNamedPort(handle_out: *Handle, name: [*:0]const u8) Result;
pub extern fn svcSendSyncRequest(handle: Handle) Result;
pub extern fn svcSendSyncRequestWithUserBuffer(buf: *anyopaque, size: usize, handle: Handle) Result;
pub extern fn svcGetProcessId(pid_out: *u64, handle: Handle) Result;
pub extern fn svcGetThreadId(tid_out: *u64, handle: Handle) Result;
pub extern fn svcBreak(reason: BreakReason, arg: u64, size: u64) Result;
pub extern fn svcOutputDebugString(str: [*]const u8, size: usize) Result;
pub extern fn svcGetInfo(out: *u64, id0: u32, handle: Handle, id1: u64) Result;

// =============================================================================
// Graphics: pixel/color formats
// =============================================================================
// The Switch's display stack is a fork of Android's gralloc/BufferQueue, and
// libnx reuses Android's HAL_PIXEL_FORMAT numbering verbatim.

pub const PixelFormat = enum(u32) {
    rgba_8888 = 1,
    rgbx_8888 = 2,
    rgb_888 = 3,
    rgb_565 = 4,
    bgra_8888 = 5,
    _,
};

// =============================================================================
// switch/display/native_window.h
// =============================================================================
// `NWindow` wraps an internal Binder/BufferQueue client (buffer-slot arrays,
// sync state, ...) whose exact layout wasn't reliably reconstructable from
// memory. Idiomatic libnx code never allocates one or reads its fields
// though — it's obtained once via `nwindowGetDefault()` and only ever passed
// around by pointer — so it's modeled as fully opaque rather than guessed
// at. `nwindowCreate` (for manual/extra layers, which DOES take
// caller-allocated storage) is intentionally omitted for the same
// ABI-risk reason as `Thread`.

pub const NWindow = opaque {};

pub extern fn nwindowGetDefault() *NWindow;
pub extern fn nwindowClose(nw: *NWindow) void;
pub extern fn nwindowSetDimensions(nw: *NWindow, width: u32, height: u32) Result;
pub extern fn nwindowSetCrop(nw: *NWindow, left: i32, top: i32, right: i32, bottom: i32) Result;
pub extern fn nwindowSetSwapInterval(nw: *NWindow, interval: u32) Result;

// =============================================================================
// switch/display/framebuffer.h
// =============================================================================
// ABI-UNCERTAIN beyond the fields shown (see the Thread note for why this
// matters): `framebufferCreate` fills CALLER-supplied storage, so verify
// `sizeof(Framebuffer)` against your libnx build before trusting a
// stack/global instance. `_reserved` is a conservative over-estimate of the
// trailing per-slot buffer bookkeeping.

pub const Framebuffer = extern struct {
    win: ?*NWindow,
    buf: ?*anyopaque,
    buf_linear: ?*anyopaque,
    fb_size: usize,
    num_fbs: u32,
    width: u32,
    height: u32,
    stride: u32,
    format: PixelFormat,
    cur_fb_slot: i32,
    has_init: bool,
    _reserved: [256]u8,
};

pub extern fn framebufferCreate(fb: *Framebuffer, win: *NWindow, width: u32, height: u32, format: PixelFormat, num_fbs: u32) Result;
pub extern fn framebufferClose(fb: *Framebuffer) void;
pub extern fn framebufferMakeLinear(fb: *Framebuffer) void;
/// Returns a pointer to the current back buffer; `out_stride` (bytes/row) may be null.
pub extern fn framebufferBegin(fb: *Framebuffer, out_stride: ?*u32) ?[*]u8;
pub extern fn framebufferEnd(fb: *Framebuffer) void;

// =============================================================================
// switch/services/vi.h — common subset
// =============================================================================

pub const ViServiceType = enum(c_int) {
    default = 0,
    application = 1,
    system = 2,
    manager = 3,
};

pub const ViLayerFlags = u32;

pub const ViScalingMode = enum(u32) {
    none = 0,
    freeze = 1,
    scale_to_window = 2,
    preserve_aspect_ratio = 3,
    _,
};

/// ABI-UNCERTAIN: field layout best-effort from memory. Obtain/release only
/// via `viOpenDefaultDisplay`/`viCloseDisplay`; avoid reading fields directly.
pub const ViDisplay = extern struct {
    display_id: u64,
    display_name: [0x40]u8,
    initialized: bool,
};

/// ABI-UNCERTAIN, see `ViDisplay` note.
pub const ViLayer = extern struct {
    is_stray_layer: bool,
    initialized: bool,
    layer_id: u64,
    igbp_binder_obj_id: i32,
    display_id: u64,
    _reserved: [32]u8,
};

pub extern fn viInitialize(service_type: ViServiceType) Result;
pub extern fn viExit() void;
pub extern fn viOpenDefaultDisplay(display: *ViDisplay) Result;
pub extern fn viCloseDisplay(display: *ViDisplay) Result;
pub extern fn viGetDisplayResolution(display: *ViDisplay, width: *u32, height: *u32) Result;
pub extern fn viGetDisplayVsyncEvent(display: *ViDisplay, event_out: *Event) Result;
// Signature best-effort — double check argument order against your libnx
// version's vi.h before relying on it.
pub extern fn viCreateManagedLayer(display: *ViDisplay, flags: ViLayerFlags, aruid: u64, layer_id_out: *u64) Result;
pub extern fn viDestroyManagedLayer(layer: *ViLayer) Result;
pub extern fn viCloseLayer(layer: *ViLayer) Result;
pub extern fn viSetLayerScalingMode(layer: *ViLayer, mode: ViScalingMode) Result;
pub extern fn viSetLayerZ(layer: *ViLayer, z: i64) Result;
pub extern fn viSetLayerSize(layer: *ViLayer, width: u32, height: u32) Result;
pub extern fn viSetLayerPosition(layer: *ViLayer, x: f32, y: f32) Result;

// =============================================================================
// switch/nvidia/nvmap.h — minimal subset (GPU-visible memory allocation)
// =============================================================================
// ABI-UNCERTAIN, see the Thread note. Signature of `nvMapCreate` in
// particular is best-effort (argument order/count for `kind`/cacheable
// flags varies across libnx versions) — verify before use.

pub const NvMap = extern struct {
    handle: u32,
    size: u32,
    cpu_addr: ?*anyopaque,
    has_init: bool,
    is_cpu_cacheable: bool,
    _reserved: [16]u8,
};

pub extern fn nvInitialize() Result;
pub extern fn nvExit() void;
pub extern fn nvMapCreate(m: *NvMap, cpu_addr: ?*anyopaque, size: u32, alignment: u32, is_cpu_cacheable: bool) Result;
pub extern fn nvMapClose(m: *NvMap) Result;

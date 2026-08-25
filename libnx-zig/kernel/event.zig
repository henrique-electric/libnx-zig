const __types = @import("../types.zig");

const Handle = __types.Handle;

/// Kernel-mode event structure.
pub const Event = extern struct {
    revent: Handle, //< Read-only event handle
    wevent: Handle, //< Write-only event handle
    autoclear: bool
};


pub extern fn eventCreate(t: *Event, autoclear: bool) __types.Result;
pub extern fn eventLoadRemote(t: *Event, handle: Handle, autoclear: bool) void;
pub extern fn eventClose(t: *Event) void;
pub extern fn eventWait(t: *Event, timeout: u64) __types.Result;
pub extern fn eventFire(t: *Event) __types.Result;
pub extern fn eventClear(t: *Event) __types.Result;
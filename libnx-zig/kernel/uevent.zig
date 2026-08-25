const __types = @import("../types.zig");
const __wait = @import("wait.zig");

const Waitable = __wait.Waitable;

/// User-mode event object.
pub const UEvent = extern struct {
    waitable: Waitable,
    signal: bool,
    auto_clear: bool
};

pub extern fn ueventCreate(e: *UEvent, auto_clear: bool) void;
pub extern fn ueventClear(e: *UEvent) void;
pub extern fn ueventSignal(e: *UEvent) void;
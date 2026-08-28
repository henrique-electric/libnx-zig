//! Zig port of libnx's `switch/kernel/event.h` ("Kernel-mode event synchronization primitive.").
//! Original author(s): plutoo.
//! Copyright (c) 2017-2018 libnx Authors. Licensed under the ISC License
//! (switchbrew/libnx) -- see /LICENSE-libnx.md at the repo root.

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
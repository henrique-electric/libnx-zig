//! Zig port of libnx's `switch/kernel/uevent.h` ("User-mode event synchronization primitive.").
//! Original author(s): plutoo.
//! Copyright (c) 2017-2018 libnx Authors. Licensed under the ISC License
//! (switchbrew/libnx) -- see /LICENSE-libnx.md at the repo root.

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
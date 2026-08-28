//! Zig port of libnx's `switch/display/native_window.h` ("Native window (NWindow) wrapper object, used for presenting images to the display (or other sinks).").
//! Original author(s): fincs.
//! Copyright (c) 2017-2018 libnx Authors. Licensed under the ISC License
//! (switchbrew/libnx) -- see /LICENSE-libnx.md at the repo root.

const __mutex = @import("../kernel/mutex.zig");
const __event = @import("../kernel/event.zig");



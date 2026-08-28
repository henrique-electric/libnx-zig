//! Zig port of libnx's `switch/arm/tls.h` ("AArch64 thread local storage.").
//! Original author(s): plutoo.
//! Copyright (c) 2017-2018 libnx Authors. Licensed under the ISC License
//! (switchbrew/libnx) -- see /LICENSE-libnx.md at the repo root.

pub inline fn armGetTls() *anyopaque {
    var ret: *anyopaque = undefined;
    asm volatile ("mrs %x[data], tpidrro_el0" : [data] "=r" (ret));
}
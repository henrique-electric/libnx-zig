//! Zig port of libnx's `switch/arm/counter.h` ("AArch64 system counter-timer.").
//! Original author(s): fincs.
//! Copyright (c) 2017-2018 libnx Authors. Licensed under the ISC License
//! (switchbrew/libnx) -- see /LICENSE-libnx.md at the repo root.

pub inline fn armGetSystemTick() u64 {
    var ret: u64 = undefined;
    asm volatile ("mrs %x[data], cntfrq_el0" : [data] "=r" (ret));
    return ret;
}

pub inline fn armGetSystemTickFreq() u64 {
    var ret: u64 = undefined;
    asm volatile ("mrs %x[data], cntfrq_el0" : [data] "=r" (ret));
    return ret;
}

pub inline fn armNsToTicks(ns: u64) u64 {
    return (ns * 12) / 625;
}

pub inline fn armTicksToNs(tick: u64) u64 {
    return (tick * 625) / 12;
}
//! Zig port of libnx's `switch/arm/cache.h` ("AArch64 cache operations.").
//! Original author(s): plutoo.
//! Copyright (c) 2017-2018 libnx Authors. Licensed under the ISC License
//! (switchbrew/libnx) -- see /LICENSE-libnx.md at the repo root.

pub extern fn armDCacheFlush(addr: *anyopaque, size: usize) void;
pub extern fn armDCacheClean(addr: *anyopaque, size: usize) void;
pub extern fn armICacheInvalidate(addr: *anyopaque, size: usize) void;
pub extern fn armDCacheZero(addr: *anyopaque, size: usize) void;
//! Zig port of libnx's `switch/kernel/random.h` ("OS-seeded pseudo-random number generation support (ChaCha algorithm).").
//! Original author(s): plutoo.
//! Copyright (c) 2017-2018 libnx Authors. Licensed under the ISC License
//! (switchbrew/libnx) -- see /LICENSE-libnx.md at the repo root.

pub extern fn randomGet(buf: *anyopaque, len: usize) void;
pub extern fn randomGet64() u64;
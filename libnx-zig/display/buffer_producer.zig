//! Zig port of libnx's `switch/display/buffer_producer.h`.
//! Copyright (c) 2017-2018 libnx Authors. Licensed under the ISC License
//! (switchbrew/libnx) -- see /LICENSE-libnx.md at the repo root.

const __types = @import("types.zig");

pub const BqRect = extern struct {
    left:   i32,
    top:    i32,
    right:  i32,
    bottom: i32,
};

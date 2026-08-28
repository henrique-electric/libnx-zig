//! Zig port of libnx's `switch/nvidia/channel.h`.
//! Copyright (c) 2017-2018 libnx Authors. Licensed under the ISC License
//! (switchbrew/libnx) -- see /LICENSE-libnx.md at the repo root.

const Result = @import("../types.zig").Result;
const __nv_types = @import("types.zig");
const __ioctl = @import("ioctl.zig");

pub const NvChannel = extern struct {
    fd:         u32,
    has_init:   bool
};

pub extern fn nvChannelCreate(c: *NvChannel, dev: [*]const u8) Result;
pub extern fn nvChannelClose(c: *NvChannel) void;

pub extern fn nvChannelSetPriority(c: *NvChannel, prio: __ioctl.NvChannelPriority) Result;
pub extern fn nvChannelSetTimeout(c: *NvChannel, timeout: u32) Result;
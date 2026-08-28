//! Zig port of libnx's `switch/nvidia/gpu.h`.
//! Copyright (c) 2017-2018 libnx Authors. Licensed under the ISC License
//! (switchbrew/libnx) -- see /LICENSE-libnx.md at the repo root.

const __types = @import("types.zig");
const __ioctl = @import("ioctl.zig");
const Result = @import("../types.zig").Result;

pub extern fn nvGpuInit() Result;
pub extern fn nvGpuExit() void;
pub extern fn nvGpuGetCharacteristics() *const __ioctl.nvioctl_gpu_characteristics;
pub extern fn nvGpuGetTpcMasks(num_masks_out: u32) *u32;

pub extern fn nvGpuZbcGetActiveSlotMask(out_slot: *u32, out_mask: *u32) Result;
pub extern fn nvGpuZbcAddColor(color_l2: [4]u32, color_ds: [4]u32, format: u32) Result;
pub extern fn nvGpuZbcAddDepth(depth: f32) Result;
pub extern fn nvGpuGetTimestamp(ts: *u64) Result;
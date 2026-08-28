//! Zig port of libnx's `switch/display/types.h` ("Definitions for Android-related types and enumerations.").
//! Copyright (c) 2017-2018 libnx Authors. Licensed under the ISC License
//! (switchbrew/libnx) -- see /LICENSE-libnx.md at the repo root.

const __types = @import("../types.zig");

pub const PixelFormat = enum(u32) {
    PIXEL_FORMAT_RGBA_8888              = 1,
    PIXEL_FORMAT_RGBX_8888              = 2,
    PIXEL_FORMAT_RGB_888                = 3,
    PIXEL_FORMAT_RGB_565                = 4,
    PIXEL_FORMAT_BGRA_8888              = 5,
    PIXEL_FORMAT_RGBA_5551              = 6,
    PIXEL_FORMAT_RGBA_4444              = 7,
    PIXEL_FORMAT_YCRCB_420_SP           = 17,
    PIXEL_FORMAT_RAW16                  = 32,
    PIXEL_FORMAT_BLOB                   = 33,
    PIXEL_FORMAT_IMPLEMENTATION_DEFINED = 34,
    PIXEL_FORMAT_YCBCR_420_888          = 35,
    PIXEL_FORMAT_Y8                     = 0x20203859,
    PIXEL_FORMAT_Y16                    = 0x20363159,
    PIXEL_FORMAT_YV12                   = 0x32315659
};



pub const NativeHandle = extern struct {
    version: i32,
    num_fds: i32,
    num_ints: i32
};
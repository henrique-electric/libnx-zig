//! Zig port of libnx's `switch/runtime/hosversion.h` ("Horizon OS (HOS) version detection utilities.").
//! Original author(s): fincs.
//! Copyright (c) 2017-2018 libnx Authors. Licensed under the ISC License
//! (switchbrew/libnx) -- see /LICENSE-libnx.md at the repo root.

pub fn MAKEHOSVERSION(_major: anytype, _minor: anytype, _micro: anytype) @TypeOf(((u32)(_major) << 16) | ((u32)(_minor) << 8) | (u32)(_micro)) {
    return ((u32)(_major) << 16) | ((u32)(_minor) << 8) | (u32)(_micro);
}

pub fn HOSVER_MAJOR(_version: anytype) @TypeOf(((_version) >> 16) & 0xFF) {
    return ((_version) >> 16) & 0xFF;
}

pub fn HOSVER_MINOR(_version: anytype) @TypeOf(((_version) >>  8) & 0xFF) {
    return ((_version) >>  8) & 0xFF;
}

pub fn HOSVER_MICRO(_version: anyopaque) @TypeOf((_version) & 0xFF) {
    return (_version) & 0xFF;
}

pub extern fn hosversionGet() u32; 
pub extern fn hosversionSet(version: u32) void;
pub extern fn hosversionIsAtmosphere() void;

pub inline fn hosversionAtLeast(major: u8, minor: u8, micro: u8) bool {
    return hosversionGet() >= MAKEHOSVERSION(major, minor, micro);
}

pub inline fn hosversionBefore(major: u8, minor: u8, micro: u8) bool {
    return !hosversionAtLeast(major, minor, micro);
}

pub inline fn hosversionBetween(major1: u8, major2: u8) bool {
    const ver = hosversionGet();
    return ver >= MAKEHOSVERSION(major1, 0, 0) and ver < MAKEHOSVERSION(major2, 0, 0);
}
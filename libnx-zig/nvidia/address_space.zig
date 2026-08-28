//! Zig port of libnx's `switch/nvidia/address_space.h`.
//! Copyright (c) 2017-2018 libnx Authors. Licensed under the ISC License
//! (switchbrew/libnx) -- see /LICENSE-libnx.md at the repo root.

const iova_t = @import("types.zig").iova_t;
const Result = @import("../types.zig").Result;
const NvKind = @import("types.zig").NvKind;

pub const NvAddressSpace = extern struct {
    fd:         u32,
    page_size:  u32,
    has_init:   bool
};

pub extern fn nvAddressSpaceCreate(a: [*c]NvAddressSpace, page_size: u32) Result;
pub extern fn nvAddressSpaceClose(a: [*c]NvAddressSpace) void;
pub extern fn nvAddressSpaceAlloc(a: [*c]NvAddressSpace, sparse: bool, size: u64, iova_out: [*c]iova_t) Result;
pub extern fn nvAddressSpaceAllocFixed(a: [*c]NvAddressSpace, sparse: bool, size: u64, iova: iova_t) Result;
pub extern fn nvAddressSpaceFree(a: [*c]NvAddressSpace, iova: iova_t, size: u64) Result;
pub extern fn nvAddressSpaceMap(a: [*c]NvAddressSpace, nvmap_handle: u32, is_gpu_cacheable: bool, kind: NvKind, iova_out: [*c]iova_t) Result;
pub extern fn nvAddressSpaceMapFixed(a: [*c]NvAddressSpace, nvmap_handle: u32, is_gpu_cacheable: bool, kind: NvKind, iova: iova_t) Result;
pub extern fn nvAddressSpaceModify(a: [*c]NvAddressSpace, iova: iova_t, offset: u64, size: u64, kind: NvKind) Result;
pub extern fn nvAddressSpaceUnmap(a: [*c]NvAddressSpace, iova: iova_t) Result;
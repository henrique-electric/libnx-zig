const std = @import("std");
const __thread = @import("libnx-zig/kernel/thread.zig");
const __mutex = @import("libnx-zig/kernel/mutex.zig");
const __event = @import("libnx-zig/kernel/event.zig");
const __uevent = @import("libnx-zig/kernel/uevent.zig");
const __wait = @import("libnx-zig/kernel/wait.zig");
const __gpu_channel = @import("libnx-zig/nvidia/gpu_channel.zig");
const __addr_space = @import("libnx-zig/nvidia/address_space.zig");
const __channel = @import("libnx-zig/nvidia/channel.zig");
const __fence = @import("libnx-zig/nvidia/fence.zig");
const __ioctl = @import("libnx-zig/nvidia/ioctl.zig");
const __nv_map = @import("libnx-zig/nvidia/map.zig");
const __framebuff = @import("libnx-zig/display/framebuffer.zig");
const __buff_producer = @import("libnx-zig/display/buffer_producer.zig");
const __disp_types = @import("libnx-zig/display/types.zig");

// ---------------------------------------------------------------------------
// ABI conformance checks: one test per ported struct/union.
//
// `structSizes.txt` is the real, on-console/emulator output of sizes.c
// (repo root), built with devkitA64 against the actual libnx.a - i.e. the
// ground truth for what each struct's size must be. It's embedded at
// compile time and searched by "<Name> (struct|union)" key, so this file
// never hardcodes an expected size: rerun sizes.c, drop its output back
// into structSizes.txt, and these tests automatically check against the
// new numbers - nothing here needs editing when that file changes.
//
// A struct with no matching key (RMutex; anything not yet present in
// structSizes.txt) has nothing to assert against yet, so its test just
// prints @sizeOf() and says so, same as before.
//
// Run with:
//   zig test tests.zig
// A FAIL means the Zig struct's field layout doesn't match what the real
// devkitA64-built libnx.a expects - see README.md's ABI risk section.
// ---------------------------------------------------------------------------

const struct_sizes_txt = @embedFile("structSizes.txt");

/// Scans structSizes.txt for a line whose (trimmed) text starts with
/// `key` (e.g. "Thread (struct)") and returns the integer that follows it,
/// or null if `key` has no entry yet.
fn expectedSize(key: []const u8) ?usize {
    var lines = std.mem.splitScalar(u8, struct_sizes_txt, '\n');
    while (lines.next()) |raw_line| {
        const line = std.mem.trimStart(u8, raw_line, " \t");
        if (!std.mem.startsWith(u8, line, key)) continue;
        const rest = std.mem.trimStart(u8, line[key.len..], " \t");
        var end: usize = 0;
        while (end < rest.len and rest[end] >= '0' and rest[end] <= '9') : (end += 1) {}
        if (end == 0) continue;
        return std.fmt.parseInt(usize, rest[0..end], 10) catch null;
    }
    return null;
}

/// Looks up `key` (the sizes.c-style "Name (kind)" label) in structSizes.txt
/// and asserts `actual` matches it. Prints either way so `zig test`'s
/// output stays useful as a running diff against sizes.c.
fn checkSize(comptime display: []const u8, key: []const u8, actual: usize) !void {
    if (expectedSize(key)) |expected| {
        std.debug.print("  {s:<58} zig={d:<6} c={d:<6} {s}\n", .{
            display, actual, expected, if (actual == expected) "OK" else "MISMATCH",
        });
        try std.testing.expectEqual(expected, actual);
    } else {
        std.debug.print("  {s:<58} zig={d:<6} c=?      (no entry in structSizes.txt yet)\n", .{ display, actual });
    }
}

// == libnx-zig/kernel/event.zig ==

test "Check Event structure size" {
    try checkSize("kernel/event.zig :: Event", "Event (struct)", @sizeOf(__event.Event));
}

// == libnx-zig/kernel/thread.zig ==

test "Check CpuRegister structure size" {
    try checkSize("kernel/thread.zig :: CpuRegister", "CpuRegister (union)", @sizeOf(__thread.CpuRegister));
}

test "Check FpuRegister structure size" {
    try checkSize("kernel/thread.zig :: FpuRegister", "FpuRegister (union)", @sizeOf(__thread.FpuRegister));
}

test "Check ThreadContext structure size" {
    try checkSize("kernel/thread.zig :: ThreadContext", "ThreadContext (struct)", @sizeOf(__thread.ThreadContext));
}

test "Check thread structure size" {
    try checkSize("kernel/thread.zig :: Thread", "Thread (struct)", @sizeOf(__thread.Thread));
}

// == libnx-zig/kernel/uevent.zig ==

test "Check UEvent structure size" {
    try checkSize("kernel/uevent.zig :: UEvent", "UEvent (struct)", @sizeOf(__uevent.UEvent));
}

// == libnx-zig/kernel/wait.zig ==

test "Check WaitableNode structure size" {
    try checkSize("kernel/wait.zig :: WaitableNode", "WaitableNode (struct)", @sizeOf(__wait.WaitableNode));
}

test "Check Waitable structure size" {
    try checkSize("kernel/wait.zig :: Waitable", "Waitable (struct)", @sizeOf(__wait.Waitable));
}

test "Check Waiter structure size" {
    try checkSize("kernel/wait.zig :: Waiter", "Waiter (struct)", @sizeOf(__wait.Waiter));
}

// == libnx-zig/kernel/mutex.zig ==
// NOTE: RMutex wraps newlib's _LOCK_RECURSIVE_T (declared in devkitA64's
// sys/lock.h, not in any libnx header), so it has no key in structSizes.txt
// and never will via sizes.c - this is the "ABI risk" case README.md warns
// about. Worth double-checking against the installed devkitA64's
// sys/lock.h by hand.

test "Check RMutex structure size" {
    try checkSize("kernel/mutex.zig :: RMutex", "RMutex (struct)", @sizeOf(__mutex.RMutex));
}

// == libnx-zig/display/types.zig ==

test "Check NativeHandle structure size" {
    try checkSize("display/types.zig :: NativeHandle", "NativeHandle (struct)", @sizeOf(__disp_types.NativeHandle));
}

// == libnx-zig/display/buffer_producer.zig ==
// NOTE: only BqRect is ported so far; BqBufferInput/BqBufferOutput/
// BqGraphicBuffer (present in structSizes.txt) still need Zig equivalents.

test "Check BqRect structure size" {
    try checkSize("display/buffer_producer.zig :: BqRect", "BqRect (struct)", @sizeOf(__buff_producer.BqRect));
}

// == libnx-zig/nvidia/address_space.zig ==

test "Check NvAddressSpace structure size" {
    try checkSize("nvidia/address_space.zig :: NvAddressSpace", "NvAddressSpace (struct)", @sizeOf(__addr_space.NvAddressSpace));
}

// == libnx-zig/nvidia/channel.zig ==

test "Check NvChannel structure size" {
    try checkSize("nvidia/channel.zig :: NvChannel", "NvChannel (struct)", @sizeOf(__channel.NvChannel));
}

// == libnx-zig/nvidia/fence.zig ==

test "Check NvMultiFence structure size" {
    try checkSize("nvidia/fence.zig :: NvMultiFence", "NvMultiFence (struct)", @sizeOf(__fence.NvMultiFence));
}

// == libnx-zig/nvidia/gpu_channel.zig ==
// NOTE: this file also declares its own `pub const NvAddressSpace = opaque{}`
// (a separate, placeholder type shadowing the real one in address_space.zig)
// - not tested here since it's opaque and not the real ported struct.

test "Check NvGpuChannel structure size" {
    try checkSize("nvidia/gpu_channel.zig :: NvGpuChannel", "NvGpuChannel (struct)", @sizeOf(__gpu_channel.NvGpuChannel));
}

// == libnx-zig/nvidia/map.zig ==

test "Check NvMap structure size" {
    try checkSize("nvidia/map.zig :: NvMap", "NvMap (struct)", @sizeOf(__nv_map.NvMap));
}

// == libnx-zig/nvidia/ioctl.zig ==

test "Check nvioctl_zcull_info structure size" {
    try checkSize("nvidia/ioctl.zig :: nvioctl_zcull_info", "nvioctl_zcull_info (struct)", @sizeOf(__ioctl.nvioctl_zcull_info));
}

test "Check nvioctl_zbc_entry structure size" {
    try checkSize("nvidia/ioctl.zig :: nvioctl_zbc_entry", "nvioctl_zbc_entry (struct)", @sizeOf(__ioctl.nvioctl_zbc_entry));
}

test "Check nvioctl_gpu_characteristics structure size" {
    try checkSize("nvidia/ioctl.zig :: nvioctl_gpu_characteristics", "nvioctl_gpu_characteristics (struct)", @sizeOf(__ioctl.nvioctl_gpu_characteristics));
}

test "Check nvioctl_va_region structure size" {
    try checkSize("nvidia/ioctl.zig :: nvioctl_va_region", "nvioctl_va_region (struct)", @sizeOf(__ioctl.nvioctl_va_region));
}

test "Check nvioctl_zbc_slot_mask structure size" {
    try checkSize("nvidia/ioctl.zig :: nvioctl_zbc_slot_mask", "nvioctl_zbc_slot_mask (struct)", @sizeOf(__ioctl.nvioctl_zbc_slot_mask));
}

test "Check nvioctl_gpu_time structure size" {
    try checkSize("nvidia/ioctl.zig :: nvioctl_gpu_time", "nvioctl_gpu_time (struct)", @sizeOf(__ioctl.nvioctl_gpu_time));
}

test "Check nvioctl_fence structure size" {
    try checkSize("nvidia/ioctl.zig :: nvioctl_fence", "nvioctl_fence (struct)", @sizeOf(__ioctl.nvioctl_fence));
}

test "Check nvioctl_gpfifo_entry structure size" {
    try checkSize("nvidia/ioctl.zig :: nvioctl_gpfifo_entry", "nvioctl_gpfifo_entry (struct)", @sizeOf(__ioctl.nvioctl_gpfifo_entry));
}

test "Check nvioctl_cmdbuf structure size" {
    try checkSize("nvidia/ioctl.zig :: nvioctl_cmdbuf", "nvioctl_cmdbuf (struct)", @sizeOf(__ioctl.nvioctl_cmdbuf));
}

test "Check nvioctl_reloc structure size" {
    try checkSize("nvidia/ioctl.zig :: nvioctl_reloc", "nvioctl_reloc (struct)", @sizeOf(__ioctl.nvioctl_reloc));
}

test "Check nvioctl_reloc_shift structure size" {
    try checkSize("nvidia/ioctl.zig :: nvioctl_reloc_shift", "nvioctl_reloc_shift (struct)", @sizeOf(__ioctl.nvioctl_reloc_shift));
}

test "Check nvioctl_syncpt_incr structure size" {
    try checkSize("nvidia/ioctl.zig :: nvioctl_syncpt_incr", "nvioctl_syncpt_incr (struct)", @sizeOf(__ioctl.nvioctl_syncpt_incr));
}

test "Check nvioctl_command_buffer_map structure size" {
    try checkSize("nvidia/ioctl.zig :: nvioctl_command_buffer_map", "nvioctl_command_buffer_map (struct)", @sizeOf(__ioctl.nvioctl_command_buffer_map));
}

test "Check nvioctl_clk_rate structure size" {
    try checkSize("nvidia/ioctl.zig :: nvioctl_clk_rate", "nvioctl_clk_rate (struct)", @sizeOf(__ioctl.nvioctl_clk_rate));
}

test "Check NvNotification structure size" {
    try checkSize("nvidia/ioctl.zig :: NvNotification", "NvNotification (struct)", @sizeOf(__ioctl.NvNotification));
}

test "Check NvError structure size" {
    try checkSize("nvidia/ioctl.zig :: NvError", "NvError (struct)", @sizeOf(__ioctl.NvError));
}

//! Zig port of libnx's `switch/sf/hipc.h` ("Horizon Inter-Process Communication protocol").
//! Original author(s): fincs, SciresM.
//! Copyright (c) 2017-2018 libnx Authors. Licensed under the ISC License
//! (switchbrew/libnx) -- see /LICENSE-libnx.md at the repo root.

const __tls = @import("../arm/tls.zig");
const __result = @import("../result.zig");
const __svc = @import("../kernel/svc.zig");

const Handle = @import("../types.zig").Handle;

pub const HIPC_AUTO_RECV_STATIC: u32 = 0xFF;
pub const HIPC_RESPONSE_NO_PID: u32 = 0xFFFFFFFF;

pub const HipcMetadata = extern struct {
    __type:             u32 = 0,
    num_send_statics:   u32 = 0,
    num_send_buffers:   u32 = 0,
    num_recv_buffers:   u32 = 0,
    num_exch_buffers:   u32 = 0,
    num_data_words:     u32 = 0,
    num_recv_statics:   u32 = 0, // also accepts HIPC_AUTO_RECV_STATIC
    send_pid:           u32 = 0,
    num_copy_handles:   u32 = 0,
    num_move_handles:   u32 = 0,
};

pub const HipcHeader = packed struct {
    __type:                 u16,
    num_send_statics:       u4,
    num_send_buffers:       u4,
    num_recv_buffers:       u4,
    num_exch_buffers:       u4,
    num_data_words:         u10,
    recv_static_mode:       u4,
    padding:                u6,
    recv_list_offset:       u11, // Unused.
    has_special_header:     u1,
};

pub const HipcSpecialHeader = packed struct {
    send_pid:           u1,
    num_copy_handles:   u4,
    num_move_handles:   u4,
    padding:            u23,
};

pub const HipcStaticDescriptor = packed struct {
    index:      u6,
    addr_high:  u6,
    addr_mid:   u4,
    size:       u16,
    addr_low:   u32,
};

// NOTE: this can't be a single monolithic `packed struct` like the others above:
// its total bit width (96) isn't a "clean" power-of-two backing size, so Zig pads
// @sizeOf/@alignOf up to 16 instead of the real 12-byte/4-byte-aligned C layout,
// which would silently corrupt every buffer-descriptor array stride below.
// Splitting the trailing 32-bit bitfield group into its own field keeps each
// piece at a size Zig packs tightly, giving the correct 12-byte layout.
pub const HipcBufferDescriptor = extern struct {
    size_low: u32,
    addr_low: u32,
    flags: packed struct(u32) {
        mode:       u2,
        addr_high:  u22,
        size_high:  u4,
        addr_mid:   u4,
    },
};

pub const HipcRecvListEntry = packed struct {
    addr_low:           u32,
    addr_high:          u16,
    size:               u16,
};

// `align(4)`: nothing in a HIPC buffer is guaranteed better than word (4-byte)
// alignment - the optional special header/PID block ahead of these arrays is an
// odd multiple of 4 bytes, so an 8-byte-aligned type here would be wrong.
pub const HipcRequest = extern struct {
    send_statics:       ?[*]align(4) HipcStaticDescriptor,
    send_buffers:       ?[*]HipcBufferDescriptor,
    recv_buffers:       ?[*]HipcBufferDescriptor,
    exch_buffers:       ?[*]HipcBufferDescriptor,
    data_words:         ?[*]u32,
    recv_list:          ?[*]align(4) HipcRecvListEntry,
    copy_handles:       ?[*]Handle,
    move_handles:       ?[*]Handle,
};

pub const HipcParsedRequest = extern struct {
    meta:          HipcMetadata,
    data:          HipcRequest,
    pid:           u64,
};

pub const HipcResponse = extern struct {
    pid:                u64,
    num_statics:        u32,
    num_data_words:     u32,
    num_copy_handles:   u32,
    num_move_handles:   u32,
    statics:            [*]align(4) HipcStaticDescriptor,
    data_words:         [*]u32,
    copy_handles:       [*]Handle,
    move_handles:       [*]Handle,
};

pub const HipcBufferMode = enum(i32) {
    HipcBufferMode_Normal    = 0,
    HipcBufferMode_NonSecure = 1,
    HipcBufferMode_Invalid   = 2,
    HipcBufferMode_NonDevice = 3,
};

pub inline fn hipcMakeSendStatic(buffer: *const anyopaque, size: usize, index: u8) HipcStaticDescriptor {
    const addr: u64 = @intFromPtr(buffer);
    return .{
        .index       = @truncate(index),
        .addr_high   = @truncate(addr >> 36),
        .addr_mid    = @truncate(addr >> 32),
        .size       = @truncate(size),
        .addr_low   = @truncate(addr),
    };
}

pub inline fn hipcMakeBuffer(buffer: *const anyopaque, size: usize, mode: HipcBufferMode) HipcBufferDescriptor {
    const addr: u64 = @intFromPtr(buffer);
    return .{
        .size_low = @truncate(size),
        .addr_low = @truncate(addr),
        .flags = .{
            .mode      = @intCast(@intFromEnum(mode)),
            .addr_high = @truncate(addr >> 36),
            .size_high = @truncate(size >> 32),
            .addr_mid  = @truncate(addr >> 32),
        },
    };
}

pub inline fn hipcMakeRecvStatic(buffer: *anyopaque, size: usize) HipcRecvListEntry {
    const addr: u64 = @intFromPtr(buffer);
    return .{
        .addr_low  = @truncate(addr),
        .addr_high = @truncate(addr >> 32),
        .size      = @truncate(size),
    };
}

// `align(4)`: descriptors always live inside a request/response array, which is
// only ever word-aligned (see the comment on HipcRequest above).
pub inline fn hipcGetStaticAddress(desc: *align(4) const HipcStaticDescriptor) *anyopaque {
    const addr: u64 = @as(u64, desc.addr_low) | (@as(u64, desc.addr_mid) << 32) | (@as(u64, desc.addr_high) << 36);
    return @ptrFromInt(addr);
}

pub inline fn hipcGetStaticSize(desc: *align(4) const HipcStaticDescriptor) usize {
    return desc.size;
}

pub inline fn hipcGetBufferAddress(desc: *const HipcBufferDescriptor) *anyopaque {
    const addr: u64 = @as(u64, desc.addr_low) | (@as(u64, desc.flags.addr_mid) << 32) | (@as(u64, desc.flags.addr_high) << 36);
    return @ptrFromInt(addr);
}

pub inline fn hipcGetBufferSize(desc: *const HipcBufferDescriptor) usize {
    return @as(usize, desc.size_low) | (@as(usize, desc.flags.size_high) << 32);
}

pub inline fn hipcCalcRequestLayout(meta: HipcMetadata, base: *anyopaque) HipcRequest {
    var p: [*]u8 = @ptrCast(base);

    // Copy handles
    var copy_handles: ?[*]Handle = null;
    if (meta.num_copy_handles != 0) {
        copy_handles = @ptrCast(@alignCast(p));
        p += @as(usize, meta.num_copy_handles) * @sizeOf(Handle);
    }

    // Move handles
    var move_handles: ?[*]Handle = null;
    if (meta.num_move_handles != 0) {
        move_handles = @ptrCast(@alignCast(p));
        p += @as(usize, meta.num_move_handles) * @sizeOf(Handle);
    }

    // Send statics
    var send_statics: ?[*]align(4) HipcStaticDescriptor = null;
    if (meta.num_send_statics != 0) {
        send_statics = @ptrCast(@alignCast(p));
        p += @as(usize, meta.num_send_statics) * @sizeOf(HipcStaticDescriptor);
    }

    // Send buffers
    var send_buffers: ?[*]HipcBufferDescriptor = null;
    if (meta.num_send_buffers != 0) {
        send_buffers = @ptrCast(@alignCast(p));
        p += @as(usize, meta.num_send_buffers) * @sizeOf(HipcBufferDescriptor);
    }

    // Recv buffers
    var recv_buffers: ?[*]HipcBufferDescriptor = null;
    if (meta.num_recv_buffers != 0) {
        recv_buffers = @ptrCast(@alignCast(p));
        p += @as(usize, meta.num_recv_buffers) * @sizeOf(HipcBufferDescriptor);
    }

    // Exch buffers
    var exch_buffers: ?[*]HipcBufferDescriptor = null;
    if (meta.num_exch_buffers != 0) {
        exch_buffers = @ptrCast(@alignCast(p));
        p += @as(usize, meta.num_exch_buffers) * @sizeOf(HipcBufferDescriptor);
    }

    // Data words
    var data_words: ?[*]u32 = null;
    if (meta.num_data_words != 0) {
        data_words = @ptrCast(@alignCast(p));
        p += @as(usize, meta.num_data_words) * @sizeOf(u32);
    }

    // Recv list
    var recv_list: ?[*]align(4) HipcRecvListEntry = null;
    if (meta.num_recv_statics != 0)
        recv_list = @ptrCast(@alignCast(p));

    return .{
        .send_statics = send_statics,
        .send_buffers = send_buffers,
        .recv_buffers = recv_buffers,
        .exch_buffers = exch_buffers,
        .data_words   = data_words,
        .recv_list    = recv_list,
        .copy_handles = copy_handles,
        .move_handles = move_handles,
    };
}

pub inline fn hipcMakeRequest(base: *anyopaque, meta: HipcMetadata) HipcRequest {
    // Write message header
    const has_special_header = meta.send_pid != 0 or meta.num_copy_handles != 0 or meta.num_move_handles != 0;

    var recv_static_mode: u32 = 0;
    if (meta.num_recv_statics != 0)
        recv_static_mode = if (meta.num_recv_statics != HIPC_AUTO_RECV_STATIC) 2 + meta.num_recv_statics else 2;

    var p: [*]u8 = @ptrCast(base);
    const hdr: *align(4) HipcHeader = @ptrCast(@alignCast(p));
    p += @sizeOf(HipcHeader);
    hdr.* = .{
        .__type             = @truncate(meta.__type),
        .num_send_statics   = @truncate(meta.num_send_statics),
        .num_send_buffers   = @truncate(meta.num_send_buffers),
        .num_recv_buffers   = @truncate(meta.num_recv_buffers),
        .num_exch_buffers   = @truncate(meta.num_exch_buffers),
        .num_data_words     = @truncate(meta.num_data_words),
        .recv_static_mode   = @truncate(recv_static_mode),
        .padding            = 0,
        .recv_list_offset   = 0,
        .has_special_header = @intFromBool(has_special_header),
    };

    // Write special header
    if (has_special_header) {
        const sphdr: *align(4) HipcSpecialHeader = @ptrCast(@alignCast(p));
        p += @sizeOf(HipcSpecialHeader);
        sphdr.* = .{
            .send_pid         = @truncate(meta.send_pid),
            .num_copy_handles = @truncate(meta.num_copy_handles),
            .num_move_handles = @truncate(meta.num_move_handles),
            .padding          = 0,
        };
        if (meta.send_pid != 0)
            p += @sizeOf(u64);
    }

    // Calculate layout
    return hipcCalcRequestLayout(meta, p);
}

pub inline fn hipcParseRequest(base: *anyopaque) HipcParsedRequest {
    // Parse message header
    var p: [*]u8 = @ptrCast(base);
    const hdr: HipcHeader = @as(*align(4) const HipcHeader, @ptrCast(@alignCast(p))).*;
    p += @sizeOf(HipcHeader);

    var num_recv_statics: u32 = 0;
    var pid: u64 = 0;

    // Parse recv static mode
    if (hdr.recv_static_mode != 0) {
        if (hdr.recv_static_mode == 2)
            num_recv_statics = HIPC_AUTO_RECV_STATIC
        else if (hdr.recv_static_mode > 2)
            num_recv_statics = hdr.recv_static_mode - 2;
    }

    // Parse special header
    var sphdr: HipcSpecialHeader = .{ .send_pid = 0, .num_copy_handles = 0, .num_move_handles = 0, .padding = 0 };
    if (hdr.has_special_header != 0) {
        sphdr = @as(*align(4) const HipcSpecialHeader, @ptrCast(@alignCast(p))).*;
        p += @sizeOf(HipcSpecialHeader);

        // Read PID descriptor
        if (sphdr.send_pid != 0) {
            const pid_ptr: *align(4) const u64 = @ptrCast(@alignCast(p));
            pid = pid_ptr.*;
            p += @sizeOf(u64);
        }
    }

    const meta: HipcMetadata = .{
        .__type             = hdr.__type,
        .num_send_statics   = hdr.num_send_statics,
        .num_send_buffers   = hdr.num_send_buffers,
        .num_recv_buffers   = hdr.num_recv_buffers,
        .num_exch_buffers   = hdr.num_exch_buffers,
        .num_data_words     = hdr.num_data_words,
        .num_recv_statics   = num_recv_statics,
        .send_pid           = sphdr.send_pid,
        .num_copy_handles   = sphdr.num_copy_handles,
        .num_move_handles   = sphdr.num_move_handles,
    };

    return .{
        .meta = meta,
        .data = hipcCalcRequestLayout(meta, p),
        .pid  = pid,
    };
}

pub inline fn hipcParseResponse(base: *anyopaque) HipcResponse {
    // Parse header
    var p: [*]u8 = @ptrCast(base);
    const hdr: HipcHeader = @as(*align(4) const HipcHeader, @ptrCast(@alignCast(p))).*;
    p += @sizeOf(HipcHeader);

    // Initialize response
    var num_copy_handles: u32 = 0;
    var num_move_handles: u32 = 0;
    var pid: u64 = HIPC_RESPONSE_NO_PID;

    // Parse special header
    if (hdr.has_special_header != 0) {
        const sphdr: HipcSpecialHeader = @as(*align(4) const HipcSpecialHeader, @ptrCast(@alignCast(p))).*;
        p += @sizeOf(HipcSpecialHeader);

        // Update response
        num_copy_handles = sphdr.num_copy_handles;
        num_move_handles = sphdr.num_move_handles;

        // Parse PID descriptor
        if (sphdr.send_pid != 0) {
            const pid_ptr: *align(4) const u64 = @ptrCast(@alignCast(p));
            pid = pid_ptr.*;
            p += @sizeOf(u64);
        }
    }

    // Copy handles
    const copy_handles: [*]Handle = @ptrCast(@alignCast(p));
    p += @as(usize, num_copy_handles) * @sizeOf(Handle);

    // Move handles
    const move_handles: [*]Handle = @ptrCast(@alignCast(p));
    p += @as(usize, num_move_handles) * @sizeOf(Handle);

    // Send statics
    const num_statics = hdr.num_send_statics;
    const statics: [*]align(4) HipcStaticDescriptor = @ptrCast(@alignCast(p));
    p += @as(usize, num_statics) * @sizeOf(HipcStaticDescriptor);

    // Data words
    const data_words: [*]u32 = @ptrCast(@alignCast(p));

    return .{
        .pid              = pid,
        .num_statics      = num_statics,
        .num_data_words   = hdr.num_data_words,
        .num_copy_handles = num_copy_handles,
        .num_move_handles = num_move_handles,
        .statics          = statics,
        .data_words       = data_words,
        .copy_handles     = copy_handles,
        .move_handles     = move_handles,
    };
}

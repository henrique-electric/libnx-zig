const __event = @import("../kernel/event.zig");
const __channel = @import("channel.zig");
const __fence = @import("fence.zig");
const __types = @import("../types.zig");
const __ioctl = @import("ioctl.zig");
const Result = @import("../types.zig").Result;
const iova_t = @import("types.zig").iova_t;

pub const GPFIFO_QUEUE_SIZE = 0x800;
pub const GPFIFO_ENTRY_NOT_MAIN = __types.BIT(9);
pub const GPFIFO_ENTRY_NO_PREFETCH = __types.BIT(31);

pub const NvAddressSpace = opaque{};

pub const NvGpuChannel = extern struct {
    base:           __channel.NvChannel,
    error_event:    __event.Event,
    object_id:      u64,
    fence:          __fence.NvFence,
    fence_incr:     u32,
    entries:        [GPFIFO_QUEUE_SIZE]__ioctl.nvioctl_gpfifo_entry,
    num_entries:    u32,
};

pub extern fn nvGpuChannelCreate(c: *NvGpuChannel, as: *NvAddressSpace, prio: __ioctl.NvChannelPriority) Result;
pub extern fn nvGpuChannelClose(c: *NvGpuChannel) void;

pub extern fn nvGpuChannelZcullBind(c: *NvGpuChannel, iova: iova_t) Result;
pub extern fn nvGpuChannelAppendEntry(c: *NvGpuChannel, start: iova_t, num_cmds: u32, flags: u32, flash_threshold: u32) Result;
pub extern fn nvGpuChannelKickoff(c: *NvGpuChannel) Result;
pub extern fn nvGpuChannelGetErrorNotification(c: *NvGpuChannel, notif: *__ioctl.NvNotification) Result;
pub extern fn nvGpuChannelGetErrorInfo(c: *NvGpuChannel, __error: *__ioctl.NvError) Result;

pub inline fn nvGpuChannelGetSyncpointId(c: *NvGpuChannel) u32 {
    return c.fence.id;
}

pub inline fn nvGpuChannelGetFence(c: *NvGpuChannel, fence_out: *__fence.NvFence) void {
    fence_out.id = c.fence.id;
    fence_out.value = c.fence.value + c.fence_incr;
}

pub inline fn nvGpuChannelIncrFence(c: *NvGpuChannel) void {
    c.fence_incr += 1;
}
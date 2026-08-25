const __ioctl = @import("ioctl.zig");
const Result = @import("../types.zig").Result;

pub const NvFence = __ioctl.nvioctl_fence;

pub const NvMultiFence = extern struct {
    num_fences: u32,
    fences: [4]NvFence,
};

pub extern fn nvFenceInit() Result;
pub extern fn nvFenceExit() void;
pub extern fn nvFenceGetFd() u32;

pub extern fn nvFenceWait(f: *NvFence, timeout_us: u32) Result;
pub inline fn nvMultiFenceCreate(mf: *NvMultiFence, fence: *const NvFence) void {
    mf.num_fences = 1;
    mf.num_fences[0] = fence.*;
}

pub extern fn nvMultiFenceWait(mf: *NvMultiFence, timeout_us: *i32) Result;

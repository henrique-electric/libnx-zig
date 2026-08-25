const __mutex = @import("mutex.zig");
const __types = @import("types.zig");
const __Result = __types.Result;

const WaiterUnion = extern union { handle: u32, waitable: *Waitable };

pub const WaiterType = enum(c_int) {
    WaiterType_Handle,
    WaiterType_HandleWithClear,
    WaiterType_Waitable,
};

pub const WaitableNode = extern struct {
    prev: *WaitableNode,
    next: *WaitableNode,
};

pub const Waitable = extern struct { vt: *const anyopaque, list: WaitableNode, mutex: __mutex.Mutex };

pub const Waiter = extern struct { __type: WaiterType, __union: WaiterUnion };

pub inline fn waiterForHandle(h: u32) Waiter {
    return .{
        .__type = .WaiterType_Handle,
        .__union = .{ .handle = h },
    };
}

pub extern fn waitObjects(idx_out: *i32, objects: [*]const Waiter, num_objects: i32, timeout: u64) __Result;
pub extern fn waitHandles(idx_out: *i32, handles: [*]const u32, num_handles: i32, timeout: u64) __Result;

pub inline fn waitSingle(w: Waiter, timeout: u64) __Result {
    var idx: i32 = undefined;
    return waitHandles(&idx, &w, 1, timeout);
}

pub inline fn waitSingleHandle(h: u32, timeout: u64) __Result {
    var idx: i32 = undefined;
    return waitHandles(&idx, &h, 1, timeout);
}
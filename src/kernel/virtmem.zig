const __types = @import("../types.zig");

const VirtmemReservation = opaque {};

pub extern fn virtmemLock() void;
pub extern fn virtmemUnlock() void;
pub extern fn virtmemFindAslr(size: usize, guard_size: usize) *anyopaque;
pub extern fn virtmemFindStack(size: usize, guard_size: usize) *anyopaque;
pub extern fn virtmemFindCodeMemory(size: usize, guard_size: usize) *anyopaque;
pub extern fn virtmemAddReservation(mem: *anyopaque, size: usize) *VirtmemReservation;
pub extern fn virtmemRemoveReservation(rv: *VirtmemReservation) void;
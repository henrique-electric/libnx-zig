const std = @import("std");
const t = @import("thread.zig");

pub fn main(init: std.process.Init) !void {
    _ = init;
    std.debug.print("{}", .{@sizeOf(t.Thread)});
}
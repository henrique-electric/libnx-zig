const __types = @import("types.zig");

pub const BqRect = extern struct {
    left:   i32,
    top:    i32,
    right:  i32,
    bottom: i32,
};

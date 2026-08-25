pub const Result = u32;

pub const ThreadFunc = *fn(*anyopaque) void;
pub const Handle = u32;

pub fn BIT(n: i32) u32 {
    return @as(u32, 1) << (n);
}

pub fn BITL(n: i32) u64 {
    return @as(u64, 1) << (n);
}


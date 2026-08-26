pub extern fn armDCacheFlush(addr: *anyopaque, size: usize) void;
pub extern fn armDCacheClean(addr: *anyopaque, size: usize) void;
pub extern fn armICacheInvalidate(addr: *anyopaque, size: usize) void;
pub extern fn armDCacheZero(addr: *anyopaque, size: usize) void;
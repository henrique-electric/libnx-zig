const __types = @import("types.zig");
const Result = @import("../types.zig").Result;


pub const NvMap = extern struct {
    handle:             u32,
    id:                 u32,
    size:               u32,
    cpu_addr:          *anyopaque,
    kind:              __types.NvKind,
    has_init:          bool,
    is_cpu_cacheble:  bool
};

pub extern fn nvMapInit() Result;
pub extern fn nvMapGetFd() u32;
pub extern fn nvMapExit() void;

pub extern fn nvMapCreate(m: *NvMap, cpu_addr: *anyopaque, size: u32, __align: u32, kind: __types.NvKind, is_cpu_cacheble: bool) Result;
pub extern fn nvMapLoadRemote(m: *NvMap, id: u32) Result;
pub extern fn nvMapClose(m: *NvMap) void;

pub inline fn nvMapGetHandle(m: *NvMap) u32 {
    return m.handle;
}

pub inline fn nvMapGetId(m: *NvMap) u32 {
    return m.id;
}

pub inline fn nvMapGetSize(m: *NvMap) u32 {
    m.size;
}

pub inline fn nvMapGetCpuAddr(m: *NvMap) *anyopaque {
    return m.cpu_addr;
}

pub inline fn nvMapIsRemote(m: *NvMap) bool {
    return !m.cpu_addr;
}

pub inline fn nvMapGetKind(m: *NvMap) __types.NvKind {
    return m.kind;
}
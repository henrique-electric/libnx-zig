const hipc = @import("hipc.zig");

pub const CMIF_IN_HEADER_MAGIC = 0x49434653;
pub const CMIF_OUT_HEADER_MAGIC = 0x4F434653;

pub const CmifCommandType = enum(i32) {
    CmifCommandType_Invalid            = 0,
    CmifCommandType_LegacyRequest      = 1,
    CmifCommandType_Close              = 2,
    CmifCommandType_LegacyControl      = 3,
    CmifCommandType_Request            = 4,
    CmifCommandType_Control            = 5,
    CmifCommandType_RequestWithContext = 6,
    CmifCommandType_ControlWithContext = 7,
};

pub const CmifDomainRequestType = enum(i32) {
    CmifDomainRequestType_Invalid     = 0,
    CmifDomainRequestType_SendMessage = 1,
    CmifDomainRequestType_Close       = 2,
};

pub const CmifInHeader = extern struct {
    magic:      u32,
    version:    u32,
    cmd_id:     u32,
    token:      u32
};

pub const CmifOutHeader = extern struct {
    
};
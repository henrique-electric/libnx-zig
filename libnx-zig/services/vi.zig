//! Zig port of libnx's `switch/services/vi.h` ("Display (vi:*) service IPC wrapper.").
//! Original author(s): yellows8.
//! Copyright (c) 2017-2018 libnx Authors. Licensed under the ISC License
//! (switchbrew/libnx) -- see /LICENSE-libnx.md at the repo root.

const __types = @import("../types.zig");
const Result = @import("../types.zig").Result;

pub const ViColorRgba4444 = u16;
pub const ViColorRgba8888 = u32;

pub const ViDisplayName = extern struct {
    data: [0x40]i8
};

pub const ViDisplay = extern struct {
    display_id:     u64,
    display_name:   ViDisplayName,
    initialized:    bool
};

pub const ViLayer = extern struct {
    layer_id:               u64,
    igbp_binder_obj_id:     u32,
    flags:                  u8 // The original newlib uses a bitfield here
};

pub const ViServiceType = enum(i32) {
    ViServiceType_Default = -1,
    ViServiceType_Application = 0,
    ViServiceType_System = 1,
    ViServiceType_Manager = 2,
};

/// Used by viCreateLayer when CreateStrayLayer is used internally
pub const ViLayerFlags = enum(i32) {
    ViLayerFlags_Default = 0x1,
};

/// Used with viSetLayerScalingMode.
pub const ViScalingMode = enum(i32) {
    ViScalingMode_None = 0x0,
    ViScalingMode_FitToLayer = 0x2,
    ViScalingMode_PreserveAspectRatio = 0x4,

    ViScalingMode_Default = .ViScalingMode_FitToLayer,
};

/// Used with viSetDisplayPowerState.
pub const ViPowerState = enum(i32) {
    ViPowerState_Off           = 0, //< Screen is off.
    ViPowerState_NotScanning   = 1, //< [3.0.0+] Screen is on, but not scanning content.
    ViPowerState_On            = 2, //< [3.0.0+] Screen is on.

    ViPowerState_On_Deprecated = 1, //< [1.0.0 - 2.3.0] Screen is on.
};

/// Used as argument to many capture functions.
pub const ViLayerStack = enum(i32) {
ViLayerStack_Default                 = 0,  //< Default layer stack, includes all layers.
    ViLayerStack_Lcd                 = 1,  //< Includes only layers for the LCD.
    ViLayerStack_Screenshot          = 2,  //< Includes only layers for user screenshots.
    ViLayerStack_Recording           = 3,  //< Includes only layers for recording videos.
    ViLayerStack_LastFrame           = 4,  //< Includes only layers for the last applet-transition frame.
    ViLayerStack_Arbitrary           = 5,  //< Captures some arbitrary layer. This is normally only for am.
    ViLayerStack_ApplicationForDebug = 6,  //< Captures layers for the current application. This is normally used by creport/debugging tools.
    ViLayerStack_Null                = 10, //< Layer stack for the empty display.
};

pub extern fn viInitialize(service_type: ViServiceType) Result;
pub extern fn viExit() void;

pub extern fn viGetSession_IApplicationDisplayService() 
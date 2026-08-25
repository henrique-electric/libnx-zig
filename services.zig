//! services.zig — hand-ported Zig bindings for a subset of libnx's **Services**
//! layer: HID (input) and the applet/system group (am, apm, set/setsys, pctl).
//!
//! Same conventions as [libnx.zig](libnx.zig) — read that file's top comment
//! first if you haven't. In short: these are `extern fn`/type declarations
//! meant to link against a real devkitA64-built `libnx.a`, not a
//! reimplementation, and structs marked `ABI-UNCERTAIN` use a padded
//! placeholder for internal fields that couldn't be reconstructed
//! byte-exactly from memory — verify `sizeof()` against your toolchain
//! before trusting a stack/global instance of one of those.
//!
//! SCOPE
//!   HID:      services/hid.h — the modern `pad.h`-style Npad API
//!             (PadState/padConfigureInput/padUpdate/...) plus basic
//!             touchscreen. The legacy `hidScanInput()`/`HidControllerID`
//!             API is deprecated upstream and intentionally not ported.
//!             Keyboard/mouse/six-axis(motion)/vibration are omitted.
//!   Applet:   services/am.h — applet type/focus/operation-mode queries,
//!             the hook system, `appletMainLoop()`, exit locking. Applet
//!             *launching* (library applets, software keyboard, etc.) is
//!             out of scope.
//!   Apm:      services/apm.h — docked/handheld performance mode + CPU
//!             boost mode.
//!   Set:      services/set.h + services/setsys.h — firmware version,
//!             system language. The bulk of setsys (the huge system-
//!             settings surface) is not ported.
//!   Pctl:     services/pctl.h — parental-controls restriction check only.
//!             ⚠ This is the lowest-confidence section in the file; see the
//!             note above that section before relying on it.
//!
//! Most of these services are already initialized for you by libnx's default
//! startup (`__appInit`) — you generally only need the `*Initialize`/`*Exit`
//! calls here if you've overridden that default.

const libnx = @import("libnx.zig");
pub const Result = libnx.Result;

// =============================================================================
// switch/services/hid.h + switch/services/pad.h — Npad input, touchscreen
// =============================================================================

pub const HidNpadIdType = enum(u32) {
    no1 = 0,
    no2 = 1,
    no3 = 2,
    no4 = 3,
    no5 = 4,
    no6 = 5,
    no7 = 6,
    no8 = 7,
    other = 0x10,
    handheld = 0x20,
    _,
};

/// Bitmask of controller "styles" (form factors) to listen for, passed to
/// `padConfigureInput`. Bits 10/11 (sometimes seen as Lagon/Lager in newer
/// libnx) are folded into `_reserved_a` below since their exact position
/// wasn't certain from memory — verify against your version's hid.h if you
/// need those specific styles.
pub const HidNpadStyleTag = packed struct(u32) {
    full_key: bool = false, // Pro Controller
    handheld: bool = false, // Joy-Con(s) in handheld grip
    joy_dual: bool = false, // Joy-Con pair, separate
    joy_left: bool = false, // Single Joy-Con (left)
    joy_right: bool = false, // Single Joy-Con (right)
    gc: bool = false, // GameCube controller
    palma: bool = false, // Poké Ball Plus
    lark: bool = false, // NES/Famicom controller
    handheld_lark: bool = false,
    lucia: bool = false, // NES controller (handheld rail)
    _reserved_a: u19 = 0,
    system_ext: bool = false,
    system: bool = false,
    _reserved_b: u1 = 0,
};

/// Bitmask returned by `padGetButtons`/`padGetButtonsDown`/`padGetButtonsUp`.
/// Cast the raw `u64` with `@bitCast` to get named fields, e.g.
/// `const btn: HidNpadButton = @bitCast(padGetButtons(&pad)); if (btn.a) ...`.
/// Bits beyond 27 (Palma/handheld-extra buttons in newer controllers) are
/// folded into `_reserved` — low confidence on their exact position.
pub const HidNpadButton = packed struct(u64) {
    a: bool = false,
    b: bool = false,
    x: bool = false,
    y: bool = false,
    stick_l: bool = false,
    stick_r: bool = false,
    l: bool = false,
    r: bool = false,
    zl: bool = false,
    zr: bool = false,
    plus: bool = false,
    minus: bool = false,
    left: bool = false,
    up: bool = false,
    right: bool = false,
    down: bool = false,
    stick_l_left: bool = false,
    stick_l_up: bool = false,
    stick_l_right: bool = false,
    stick_l_down: bool = false,
    stick_r_left: bool = false,
    stick_r_up: bool = false,
    stick_r_right: bool = false,
    stick_r_down: bool = false,
    left_sl: bool = false,
    left_sr: bool = false,
    right_sl: bool = false,
    right_sr: bool = false,
    _reserved: u36 = 0,
};

pub const HidAnalogStickState = extern struct {
    x: i32,
    y: i32,
};

/// ABI-UNCERTAIN beyond the fields shown — the real `PadState` also carries
/// internal six-axis-sensor handles and repeat-timer bookkeeping past
/// `analog_stick_r` whose exact layout wasn't reconstructable from memory.
/// `padInitializeDefault`/`padInitializeWithMask` write into CALLER-supplied
/// storage, so the same caution as `Thread` in libnx.zig applies: verify
/// `sizeof(PadState)` before trusting a stack/global instance.
pub const PadState = extern struct {
    id: HidNpadIdType,
    style_set: u32, // bit-cast to/from HidNpadStyleTag
    attributes: u32,
    buttons: u64, // bit-cast to/from HidNpadButton
    buttons_cur: u64,
    buttons_old: u64,
    analog_stick_l: HidAnalogStickState,
    analog_stick_r: HidAnalogStickState,
    _reserved: [256]u8,
};

/// Must be called once (per style set you care about) before any
/// `padInitialize*`/`padUpdate` calls.
pub extern fn padConfigureInput(max_supported_players: i32, style_set: u32) void;
pub extern fn padInitializeDefault(pad: *PadState) void;
pub extern fn padInitializeWithMask(pad: *PadState, npad_id_mask: u64) void;
pub extern fn padUpdate(pad: *PadState) void;
pub extern fn padIsConnected(pad: *const PadState) bool;
pub extern fn padGetButtons(pad: *const PadState) u64;
pub extern fn padGetButtonsDown(pad: *const PadState) u64;
pub extern fn padGetButtonsUp(pad: *const PadState) u64;
pub extern fn padGetStickPos(pad: *const PadState, stick: i32) HidAnalogStickState;
pub extern fn padGetAttributes(pad: *const PadState) u32;

/// ABI-UNCERTAIN: field layout best-effort; the 16-touch capacity in
/// particular is a commonly-cited figure, not something re-derived here —
/// verify before relying on a stack/global instance (this struct is filled
/// in place by `hidGetTouchScreenStates`, same caller-storage caveat as
/// elsewhere in this file).
pub const HidTouchState = extern struct {
    delta_time: u64,
    attributes: u32,
    finger_id: u32,
    x: i32,
    y: i32,
    diameter_x: i32,
    diameter_y: i32,
    rotation_angle: i32,
};

pub const HidTouchScreenState = extern struct {
    sampling_number: u64,
    count: i32,
    touches: [16]HidTouchState,
};

/// Returns the number of states actually written (0 or 1 in practice — pass
/// `max_states = 1` for "just the latest screen state", the common case).
pub extern fn hidGetTouchScreenStates(states: [*]HidTouchScreenState, max_states: i32) i32;

// =============================================================================
// switch/services/am.h — applet lifecycle/focus/hooks (common subset)
// =============================================================================

pub const AppletType = enum(i32) {
    none = -2,
    default = -1,
    application = 0,
    system_applet = 1,
    library_applet = 2,
    overlay_applet = 3,
    system_application = 4,
};

pub const AppletFocusState = enum(u32) {
    in_focus = 1,
    out_of_focus = 2,
    background = 3,
    _,
};

pub const AppletOperationMode = enum(u32) {
    handheld = 0,
    console = 1,
    _,
};

pub const AppletHookType = enum(c_int) {
    on_focus_state = 0,
    on_operation_mode = 1,
    on_performance_mode = 2,
    on_exit_request = 3,
    on_resume = 4,
    on_capture_button_short_pressed = 5,
    on_album_screen_shot_taken = 6,
    request_to_display = 7,
    _,
};

pub const AppletHookFn = *const fn (hook: AppletHookType, param: ?*anyopaque) callconv(.c) void;

/// Public/user-allocated intrusive linked-list node — unlike most structs
/// flagged elsewhere in this port, libnx's own am.h defines this one fully
/// for application use, so it's low ABI risk despite being caller-allocated.
pub const AppletHookCookie = extern struct {
    next: ?*AppletHookCookie,
    callback: ?AppletHookFn,
    param: ?*anyopaque,
};

pub extern fn appletGetAppletType() AppletType;
pub extern fn appletGetFocusState() AppletFocusState;
pub extern fn appletGetOperationMode() AppletOperationMode;
pub extern fn appletGetAppletResourceUserId(out: *u64) Result;
/// Pumps applet state/events; returns `false` once the app should exit
/// (typically the loop condition of your whole program: `while (appletMainLoop()) { ... }`).
pub extern fn appletMainLoop() bool;
pub extern fn appletHook(cookie: *AppletHookCookie, callback: AppletHookFn, param: ?*anyopaque) void;
pub extern fn appletUnhook(cookie: *AppletHookCookie) void;
/// Delays a HOME-menu-initiated close until `appletUnlockExit` is called —
/// use to guarantee your own cleanup runs first.
pub extern fn appletLockExit() Result;
pub extern fn appletUnlockExit() void;

// =============================================================================
// switch/services/apm.h — performance mode
// =============================================================================

pub const ApmPerformanceMode = enum(i32) {
    invalid = -1,
    normal = 0,
    boost = 1,
};

pub const ApmCpuBoostMode = enum(u32) {
    disabled = 0,
    type1 = 1,
    type2 = 2,
    _,
};

pub extern fn apmInitialize() Result;
pub extern fn apmExit() void;
pub extern fn apmGetPerformanceMode(out_perf_mode: *ApmPerformanceMode) Result;
pub extern fn apmSetCpuBoostMode(mode: ApmCpuBoostMode) Result;

// =============================================================================
// switch/services/set.h + switch/services/setsys.h — common subset
// =============================================================================

/// Confident on total size (0x100 bytes — a widely-cited figure), including
/// the 2-byte gap before `version_hash`; field names/order are best-effort
/// otherwise.
pub const SetSysFirmwareVersion = extern struct {
    major: u8,
    minor: u8,
    micro: u8,
    _padding1: u8,
    revision_major: u8,
    revision_minor: u8,
    platform: [0x20]u8,
    _padding2: [2]u8,
    version_hash: [0x40]u8,
    display_version: [0x18]u8,
    display_title: [0x80]u8,
};
comptime {
    @import("std").debug.assert(@sizeOf(SetSysFirmwareVersion) == 0x100);
}

pub extern fn setsysInitialize() Result;
pub extern fn setsysExit() void;
pub extern fn setsysGetFirmwareVersion(out: *SetSysFirmwareVersion) Result;

pub extern fn setInitialize() Result;
pub extern fn setExit() void;
/// Signature/semantics best-effort: `language_code` is a packed ASCII tag
/// (e.g. bytes of "en-US"), not an enum value — verify against your libnx
/// version before relying on it.
pub extern fn setGetSystemLanguage(language_code: *u64) Result;

// =============================================================================
// switch/services/pctl.h — parental controls
// =============================================================================
// ⚠ LOWEST CONFIDENCE SECTION OF THIS FILE. pctl sees little homebrew use,
// and this is a best-effort sketch rather than a verified port — check it
// against switch/services/pctl.h before depending on it for anything.

pub const PctlServiceType = enum(c_int) {
    manager = 0,
    system = 1,
    _,
};

pub extern fn pctlInitialize() Result;
pub extern fn pctlExit() void;
pub extern fn pctlIsRestrictionEnabled(out: *bool) Result;

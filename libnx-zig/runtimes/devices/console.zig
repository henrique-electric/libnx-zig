pub const PrintConsole = opaque {};

/// Renderer interface for the console.
pub const ConsoleRenderer = extern struct {
    init:           *const fn(con: *PrintConsole) callconv(.c) bool,
    deinit:         *const fn(con: *PrintConsole) callconv(.c) void,
    drawChar:       *const fn(con: *PrintConsole, x: i32, y: i32, c: i32) callconv(.c) void,
    scrollWindow:   *const fn(con: *PrintConsole) callconv(.c) void,
    flushAndSwap:   *const fn(con: *PrintConsole) callconv(.c) void
};

/// A font struct for the console.
pub const ConsoleFont = extern struct {
    gfx:         *const anyopaque,
    asciiOffset: u16,
    numChars:    u16,
    titleWidth:  u16,
    titleHeight: u16
};

pub extern fn consoleInit(console: ?*PrintConsole) *PrintConsole;
pub extern fn consoleUpdate(console: ?*PrintConsole) void;
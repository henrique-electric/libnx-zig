pub const PrintConsole = opaque {};

/// Renderer interface for the console.
pub const ConsoleRenderer = extern struct {
    init:           *fn(con: *PrintConsole) bool,
    deinit:         *fn(con: *PrintConsole) void,
    drawChar:       *fn(con: *PrintConsole, x: i32, y: i32, c: i32) void,
    scrollWindow:   *fn(con: *PrintConsole) void,
    flushAndSwap:   *fn(con: *PrintConsole) void
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
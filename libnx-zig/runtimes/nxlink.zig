pub const in_addr = opaque {};

pub extern var __nxlink_host: in_addr;

pub const NXLINK_SERVER_PORT = 28280;
pub const NXLINK_CLIENT_PORT = 28771;

pub extern fn nxlinkConnectToHost(redirStdout: bool, redirStderr: bool) i32;

pub inline fn nxlinkStdio() i32 {
    return nxlinkConnectToHost(true, true);
}

pub inline fn nxlinkStdioForDebug() i32 {
    return nxlinkConnectToHost(false, true);
}
pub inline fn RGBA8(r: anytype, g: anytype, b: anytype, a: anytype) @TypeOf((((r & @as(c_int, 0xff)) | ((g & @as(c_int, 0xff)) << @as(c_int, 8))) | ((b & @as(c_int, 0xff)) << @as(c_int, 16))) | ((a & @as(c_int, 0xff)) << @as(c_int, 24))) {
    return (((r & @as(c_int, 0xff)) | ((g & @as(c_int, 0xff)) << @as(c_int, 8))) | ((b & @as(c_int, 0xff)) << @as(c_int, 16))) | ((a & @as(c_int, 0xff)) << @as(c_int, 24));
}
pub inline fn RGBA8_MAXALPHA(r: anytype, g: anytype, b: anytype) @TypeOf(RGBA8(r, g, b, @as(c_int, 0xff))) {
    return RGBA8(r, g, b, @as(c_int, 0xff));
}
pub inline fn RGBX8(r: anytype, g: anytype, b: anytype) @TypeOf(RGBA8(r, g, b, @as(c_int, 0))) {

    return RGBA8(r, g, b, @as(c_int, 0));
}
pub inline fn RGB565(r: anytype, g: anytype, b: anytype) @TypeOf(((b & @as(c_int, 0x1f)) | ((g & @as(c_int, 0x3f)) << @as(c_int, 5))) | ((r & @as(c_int, 0x1f)) << @as(c_int, 11))) {
   
    return ((b & @as(c_int, 0x1f)) | ((g & @as(c_int, 0x3f)) << @as(c_int, 5))) | ((r & @as(c_int, 0x1f)) << @as(c_int, 11));
}
pub inline fn RGB565_FROM_RGB8(r: anytype, g: anytype, b: anytype) @TypeOf(RGB565(r >> @as(c_int, 3), g >> @as(c_int, 2), b >> @as(c_int, 3))) {
 
    return RGB565(r >> @as(c_int, 3), g >> @as(c_int, 2), b >> @as(c_int, 3));
}
pub inline fn BGRA8(r: anytype, g: anytype, b: anytype, a: anytype) @TypeOf(RGBA8(b, g, r, a)) {
 
    return RGBA8(b, g, r, a);
}
pub inline fn BGRA8_MAXALPHA(r: anytype, g: anytype, b: anytype) @TypeOf(RGBA8(b, g, r, @as(c_int, 0xff))) {

    return RGBA8(b, g, r, @as(c_int, 0xff));
}
pub inline fn RGBA4(r: anytype, g: anytype, b: anytype, a: anytype) @TypeOf((((r & @as(c_int, 0xf)) | ((g & @as(c_int, 0xf)) << @as(c_int, 4))) | ((b & @as(c_int, 0xf)) << @as(c_int, 8))) | ((a & @as(c_int, 0xf)) << @as(c_int, 12))) {

    return (((r & @as(c_int, 0xf)) | ((g & @as(c_int, 0xf)) << @as(c_int, 4))) | ((b & @as(c_int, 0xf)) << @as(c_int, 8))) | ((a & @as(c_int, 0xf)) << @as(c_int, 12));
}
pub inline fn RGBA4_MAXALPHA(r: anytype, g: anytype, b: anytype) @TypeOf(RGBA4(r, g, b, @as(c_int, 0xf))) {

    return RGBA4(r, g, b, @as(c_int, 0xf));
}
pub inline fn RGBA4_FROM_RGBA8(r: anytype, g: anytype, b: anytype, a: anytype) @TypeOf(RGBA4(r >> @as(c_int, 4), g >> @as(c_int, 4), b >> @as(c_int, 4), a >> @as(c_int, 4))) {

    return RGBA4(r >> @as(c_int, 4), g >> @as(c_int, 4), b >> @as(c_int, 4), a >> @as(c_int, 4));
}
pub inline fn RGBA4_FROM_RGBA8_MAXALPHA(r: anytype, g: anytype, b: anytype) @TypeOf(RGBA4_MAXALPHA(r >> @as(c_int, 4), g >> @as(c_int, 4), b >> @as(c_int, 4))) {

    return RGBA4_MAXALPHA(r >> @as(c_int, 4), g >> @as(c_int, 4), b >> @as(c_int, 4));
}


const Framebuffer = extern struct {
    
};
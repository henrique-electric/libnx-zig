const __types = @import("types.zig");

const _NV_IOC_NRBITS = 8;
const _NV_IOC_TYPEBITS = 8;
const _NV_IOC_SIZEBITS = 14;
const _NV_IOC_DIRBITS = 2;

const _NV_IOC_NRMASK = (1 << _NV_IOC_NRBITS) - 1;
const _NV_IOC_TYPEMASK = (1 << _NV_IOC_TYPEBITS) - 1;
const _NV_IOC_SIZEMASK = (1 << _NV_IOC_SIZEBITS) - 1;
const _NV_IOC_DIRMASK = (1 << _NV_IOC_DIRBITS) - 1;

const _NV_IOC_NRSHIFT = 0;
const _NV_IOC_TYPESHIFT	= _NV_IOC_NRSHIFT+_NV_IOC_NRBITS;

const _NV_IOC_SIZESHIFT	= _NV_IOC_TYPESHIFT+_NV_IOC_TYPEBITS;
const _NV_IOC_DIRSHIFT	= _NV_IOC_SIZESHIFT+_NV_IOC_SIZEBITS;

const _NV_IOC_NONE = 0;
const _NV_IOC_WRITE = 1;
const _NV_IOC_READ = 2;

pub inline fn _NV_IOC(dir: anytype, __type: anytype, nr: anytype, size: anytype) @TypeOf((((dir)  << _NV_IOC_DIRSHIFT) | ((__type) << _NV_IOC_TYPESHIFT) | ((nr)   << _NV_IOC_NRSHIFT) |  ((size) << _NV_IOC_SIZESHIFT))) {
    return (((dir)  << _NV_IOC_DIRSHIFT) | ((__type) << _NV_IOC_TYPESHIFT) | ((nr)   << _NV_IOC_NRSHIFT) |  ((size) << _NV_IOC_SIZESHIFT));
}

pub inline fn _NV_IO(__type: anytype, nr: anytype) @TypeOf(_NV_IOC(_NV_IOC_NONE, __type, nr, 0)) {
    return _NV_IOC(_NV_IOC_NONE, __type, nr, 0);
}

pub inline fn NV_IOR(__type: anytype, nr: anytype, size: anytype)
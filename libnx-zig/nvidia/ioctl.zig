//! Zig port of libnx's `switch/nvidia/ioctl.h`.
//! Copyright (c) 2017-2018 libnx Authors. Licensed under the ISC License
//! (switchbrew/libnx) -- see /LICENSE-libnx.md at the repo root.

const __types = @import("types.zig");
const __root_types  = @import("../types.zig");
const Result = __root_types.Result;

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

// ================== used to create numbers ==================
pub inline fn _NV_IOC(dir: anytype, __type: anytype, nr: anytype, size: anytype) @TypeOf((((dir)  << _NV_IOC_DIRSHIFT) | ((__type) << _NV_IOC_TYPESHIFT) | ((nr)   << _NV_IOC_NRSHIFT) |  ((size) << _NV_IOC_SIZESHIFT))) {
    return (((dir)  << _NV_IOC_DIRSHIFT) | ((__type) << _NV_IOC_TYPESHIFT) | ((nr)   << _NV_IOC_NRSHIFT) |  ((size) << _NV_IOC_SIZESHIFT));
}

pub inline fn _NV_IO(__type: anytype, nr: anytype) @TypeOf(_NV_IOC(_NV_IOC_NONE, __type, nr, 0)) {
    return _NV_IOC(_NV_IOC_NONE, __type, nr, 0);
}

pub inline fn NV_IOR(__type: anytype, nr: anytype, size: anytype) @TypeOf(_NV_IOC(_NV_IOC_READ, __type, nr, @sizeOf(size))) {
    return _NV_IOC(_NV_IOC_READ, __type, nr, @sizeOf(size));
}

pub inline fn _NV_IOW(__type: anytype, nr: anytype, size: anytype) @TypeOf(_NV_IOC(_NV_IOC_WRITE, __type, nr, @sizeOf(size))) {
    return _NV_IOC(_NV_IOC_WRITE, __type, nr, @sizeOf(size));
}

pub inline fn _NV_IOWR(__type: anytype, nr: anytype, size: anytype) @TypeOf(_NV_IOC(_NV_IOC_WRITE | _NV_IOC_READ, __type, nr, @sizeOf(size))) {
    return _NV_IOC(_NV_IOC_WRITE | _NV_IOC_READ, __type, nr, @sizeOf(size));
}
// ================================================================

// ================ used to decode ioctl numbers.. ===============
pub inline fn _NV_IOC_DIR(nr: anytype) @TypeOf(((nr) >> _NV_IOC_DIRSHIFT) & _NV_IOC_DIRMASK) {
    return ((nr) >> _NV_IOC_DIRSHIFT) & _NV_IOC_DIRMASK;
}

pub inline fn _NV_IOC_TYPE(nr: anytype) @TypeOf(((nr) >> _NV_IOC_TYPESHIFT) & _NV_IOC_TYPEMASK) {
    return ((nr) >> _NV_IOC_TYPESHIFT) & _NV_IOC_TYPEMASK;
}

pub inline fn _NV_IOC_NR(nr: anytype) @TypeOf(((nr) >> _NV_IOC_NRSHIFT) & _NV_IOC_NRMASK) {
    return ((nr) >> _NV_IOC_NRSHIFT) & _NV_IOC_NRMASK;
}

pub inline fn _NV_IOC_SIZE(nr: anytype) @TypeOf(((nr) >> _NV_IOC_SIZESHIFT) & _NV_IOC_SIZEMASK) {
    return ((nr) >> _NV_IOC_SIZESHIFT) & _NV_IOC_SIZEMASK;
}
// =================================================================


pub const nvioctl_zcull_info = extern struct {
    width_align_pixels:             u32,               // 0x20  (32)
    height_align_pixels:            u32,               // 0x20  (32)
    pixel_squares_by_aliquots:      u32,               // 0x400 (1024)
    aliquot_total:                  u32,               // 0x800 (2048)
    region_byte_multiplier:         u32,               // 0x20  (32)
    region_header_size:             u32,               // 0x20  (32)
    subregion_header_size:          u32,               // 0xC0  (192)
    subregion_width_align_pixels:   u32,               // 0x20  (32)
    subregion_height_align_pixels:  u32,               // 0x40  (64)
    subregion_count:                u32,               // 0x10  (16)
};

pub const nvioctl_zbc_entry = extern struct {
    color_ds: [4]u32,
    color_l2: [4]u32,
    depth:       u32,
    ref_cnt:     u32,
    format:      u32,
    @"type":     u32,
    size:        u32
};

pub const nvioctl_gpu_characteristics = extern struct {
    arch:                       u32,    // 0x120 (NVGPU_GPU_ARCH_GM200)
    impl:                       u32,    // 0xB (NVGPU_GPU_IMPL_GM20B)
    rev:                        u32,    // 0xA1 (Revision A1)
    num_gpc:                    u32,    // 0x1
    L2_cache_size:              u64,    // 0x40000
    on_board_video_memory_size: u64,    // 0x0 (not used)
    num_tpc_per_gpc:            u32,    // 0x2
    bus_type:                   u32,    // 0x20 (NVGPU_GPU_BUS_TYPE_AXI)
    big_page_size:              u32,    // 0x20000
    compression_page_size:      u32,    // 0x20000
    pde_coverage_bit_count:     u32,    // 0x1B
    available_big_page_sizes:   u32,    // 0x30000
    gpc_mask:                   u32,    // 0x1
    sm_arch_sm_version:         u32,    // 0x503 (Maxwell Generation 5.0.3?)
    sm_arch_spa_version:        u32,    // 0x503 (Maxwell Generation 5.0.3?)
    sm_arch_warp_count:         u32,    // 0x80
    gpu_va_bit_count:           u32,    // 0x28
    reserved:                   u32,    // NULL
    flags:                      u64,    // 0x55
    twod_class:                 u32,    // 0x902D (FERMI_TWOD_A)
    threed_class:               u32,    // 0xB197 (MAXWELL_B)
    compute_class:              u32,    // 0xB1C0 (MAXWELL_COMPUTE_B)
    gpfifo_class:               u32,    // 0xB06F (MAXWELL_CHANNEL_GPFIFO_A)
    inline_to_memory_class:     u32,    // 0xA140 (KEPLER_INLINE_TO_MEMORY_B)
    dma_copy_class:             u32,    // 0xB0B5 (MAXWELL_DMA_COPY_A)
    max_fbps_count:             u32,    // 0x1
    fbp_en_mask:                u32,    // 0x0 (disabled)
    max_ltc_per_fbp:            u32,    // 0x2
    max_lts_per_ltc:            u32,    // 0x1
    max_tex_per_tpc:            u32,    // 0x0 (not supported)
    max_gpc_count:              u32,    // 0x1
    rop_l2_en_mask_0:           u32,    // 0x21D70 (fuse_status_opt_rop_l2_fbp_r)
    rop_l2_en_mask_1:           u32,    // 0x0
    chipname:                   u64,    // 0x6230326D67 ("gm20b")
    gr_compbit_store_base_hw:   u64,    // 0x0 (not supported)
}; 

pub const nvioctl_va_region = extern struct {
    offset:     u64,
    page_size:  u32,
    pad:        u32,
    pages:      u64
};

pub const nvioctl_zbc_slot_mask = extern struct {
    slot: u32,
    mask: u32
};

pub const nvioctl_gpu_time = extern struct {
    timestamp:  u64,
    reserver:   u64
};

pub const nvioctl_fence = extern struct {
    id:     u32,
    value:  u32
};

pub const nvioctl_gpfifo_entry = extern struct {
    __union: extern union {
        desc:      u64,
        desc32: [2]u32
    }
};

pub const nvioctl_cmdbuf = extern struct {
    mem:    u32,
    offset: u32,
    words:  u32
};

pub const nvioctl_reloc = extern struct {
    cmdbuf_mem:     u32,
    cmdbuf_offset:  u32,
    target:         u32,
    target_offset:  u32
};

pub const nvioctl_reloc_shift = extern struct {
    shift: u32
};

pub const nvioctl_syncpt_incr = extern struct {
    syncpt_id:      u32,
    syncpt_incrs:   u32,
    waitbase_id:    u32,
    next:           u32,
    prev:           u32
};

pub const nvioctl_command_buffer_map = extern struct {
    handle: u32,
    iova:   u32,
};

pub const nvioctl_clk_rate = extern struct {
    rate:     u32,
    moduleid: u32
};

pub const NVGPU_ZBC_TYPE_INVALID = 0;
pub const NVGPU_ZBC_TYPE_COLOR = 1;
pub const NVGPU_ZBC_TYPE_DEPTH = 2;

pub const NvMapParam = enum(i32) {
    NvMapParam_Size = 1,
    NvMapParam_Alignment = 2,
    NvMapParam_Base = 3,
    NvMapParam_Heap = 4,
    NvMapParam_Kind = 5
};

pub const NvClassNumber = enum(i32) {
    NvClassNumber_2D = 0x902D,
    NvClassNumber_3D = 0xB197,
    NvClassNumber_Compute = 0xB1C0,
    NvClassNumber_Kepler = 0xA140,
    NvClassNumber_DMA = 0xB0B5,
    NvClassNumber_ChannelGpfifo = 0xB06F
};

pub const NvChannelPriority = enum(i32) {
    NvChannelPriority_Low    = 50,
    NvChannelPriority_Medium = 100,
    NvChannelPriority_High   = 150
};

pub const NvZcullConfig = enum(i32) {
    NvZcullConfig_Global = 0,
    NvZcullConfig_NoCtxSwitch = 1,
    NvZcullConfig_SeparateBuffer = 2,
    NvZcullConfig_PartOfRegularBuffer = 3
};

pub const NvAllocSpaceFlags = enum(i32) {
    NvAllocSpaceFlags_FixedOffset = 1,
    NvAllocSpaceFlags_Sparse = 2,
};

pub const NvMapBufferFlags = enum(i32) {
    NvMapBufferFlags_FixedOffset = 1,
    NvMapBufferFlags_IsCacheable = 4,
    NvMapBufferFlags_Modify = 0x100,
};

pub const NvNotificationType = enum(i32) {
    NvNotificationType_FifoErrorIdleTimeout=8,
    NvNotificationType_GrErrorSwNotify=13,
    NvNotificationType_GrSemaphoreTimeout=24,
    NvNotificationType_GrIllegalNotify=25,
    NvNotificationType_FifoErrorMmuErrFlt=31,
    NvNotificationType_PbdmaError=32,
    NvNotificationType_ResetChannelVerifError=43,
    NvNotificationType_PbdmaPushbufferCrcMismatch=80
};

pub const NvNotification = extern struct {
    timestamp:  u64,
    info32:     u32,
    info16:     u16,
    status:     u16
};

pub const NvError = extern struct {
    __type:   u32,
    info: [31]u32
};


pub extern fn nvioctlNvhostCtrl_SyncptRead(fd: u32, id: u32, out: [*c]u32) Result;
pub extern fn nvioctlNvhostCtrl_SyncptIncr(fd: u32, id: u32) Result;
pub extern fn nvioctlNvhostCtrl_SyncptWait(fd: u32, id: u32, threshold: u32, timeout: u32) Result;
pub extern fn nvioctlNvhostCtrl_EventSignal(fd: u32, event_id: u32) Result;
pub extern fn nvioctlNvhostCtrl_EventWait(fd: u32, syncpt_id: u32, threshold: u32, timeout: i32, event_id: u32, out: [*c]u32) Result;
pub extern fn nvioctlNvhostCtrl_EventWaitAsync(fd: u32, syncpt_id: u32, threshold: u32, timeout: i32, event_id: u32) Result;
pub extern fn nvioctlNvhostCtrl_EventRegister(fd: u32, event_id: u32) Result;
pub extern fn nvioctlNvhostCtrl_EventUnregister(fd: u32, event_id: u32) Result;
pub extern fn nvioctlNvhostCtrlGpu_ZCullGetCtxSize(fd: u32, out: [*c]u32) Result;
pub extern fn nvioctlNvhostCtrlGpu_ZCullGetInfo(fd: u32, out: [*c]nvioctl_zcull_info) Result;
pub extern fn nvioctlNvhostCtrlGpu_ZbcSetTable(fd: u32, color_ds: [*c]const u32, color_l2: [*c]const u32, depth: u32, format: u32, @"type": u32) Result;
pub extern fn nvioctlNvhostCtrlGpu_ZbcQueryTable(fd: u32, index: u32, out: [*c]nvioctl_zbc_entry) Result;
pub extern fn nvioctlNvhostCtrlGpu_GetCharacteristics(fd: u32, out: [*c]nvioctl_gpu_characteristics) Result;
pub extern fn nvioctlNvhostCtrlGpu_GetTpcMasks(fd: u32, buffer: ?*anyopaque, size: usize) Result;
pub extern fn nvioctlNvhostCtrlGpu_ZbcGetActiveSlotMask(fd: u32, out: [*c]nvioctl_zbc_slot_mask) Result;
pub extern fn nvioctlNvhostCtrlGpu_GetGpuTime(fd: u32, out: [*c]nvioctl_gpu_time) Result;
pub extern fn nvioctlNvhostAsGpu_BindChannel(fd: u32, channel_fd: u32) Result;
pub extern fn nvioctlNvhostAsGpu_AllocSpace(fd: u32, pages: u32, page_size: u32, flags: u32, align_or_offset: u64, offset: [*c]u64) Result;
pub extern fn nvioctlNvhostAsGpu_FreeSpace(fd: u32, offset: u64, pages: u32, page_size: u32) Result;
pub extern fn nvioctlNvhostAsGpu_MapBufferEx(fd: u32, flags: u32, kind: u32, nvmap_handle: u32, page_size: u32, buffer_offset: u64, mapping_size: u64, input_offset: u64, offset: [*c]u64) Result;
pub extern fn nvioctlNvhostAsGpu_UnmapBuffer(fd: u32, offset: u64) Result;
pub extern fn nvioctlNvhostAsGpu_GetVARegions(fd: u32, regions: [*c]nvioctl_va_region) Result;
pub extern fn nvioctlNvhostAsGpu_InitializeEx(fd: u32, flags: u32, big_page_size: u32) Result;
pub extern fn nvioctlNvmap_Create(fd: u32, size: u32, nvmap_handle: [*c]u32) Result;
pub extern fn nvioctlNvmap_FromId(fd: u32, id: u32, nvmap_handle: [*c]u32) Result;
pub extern fn nvioctlNvmap_Alloc(fd: u32, nvmap_handle: u32, heapmask: u32, flags: u32, @"align": u32, kind: u8, addr: ?*anyopaque) Result;
pub extern fn nvioctlNvmap_Free(fd: u32, nvmap_handle: u32) Result;
pub extern fn nvioctlNvmap_Param(fd: u32, nvmap_handle: u32, param: NvMapParam, result: [*c]u32) Result;
pub extern fn nvioctlNvmap_GetId(fd: u32, nvmap_handle: u32, id: [*c]u32) Result;
pub extern fn nvioctlChannel_SetNvmapFd(fd: u32, nvmap_fd: u32) Result;
pub extern fn nvioctlChannel_SubmitGpfifo(fd: u32, entries: [*c]nvioctl_gpfifo_entry, num_entries: u32, flags: u32, fence_inout: [*c]nvioctl_fence) Result;
pub extern fn nvioctlChannel_KickoffPb(fd: u32, entries: [*c]nvioctl_gpfifo_entry, num_entries: u32, flags: u32, fence_inout: [*c]nvioctl_fence) Result;
pub extern fn nvioctlChannel_AllocObjCtx(fd: u32, class_num: u32, flags: u32, id_out: [*c]u64) Result;
pub extern fn nvioctlChannel_ZCullBind(fd: u32, gpu_va: u64, mode: u32) Result;
pub extern fn nvioctlChannel_SetErrorNotifier(fd: u32, enable: u32) Result;
pub extern fn nvioctlChannel_GetErrorInfo(fd: u32, out: [*c]NvError) Result;
pub extern fn nvioctlChannel_GetErrorNotification(fd: u32, out: [*c]NvNotification) Result;
pub extern fn nvioctlChannel_SetPriority(fd: u32, priority: u32) Result;
pub extern fn nvioctlChannel_SetTimeout(fd: u32, timeout: u32) Result;
pub extern fn nvioctlChannel_AllocGpfifoEx2(fd: u32, num_entries: u32, flags: u32, unk0: u32, unk1: u32, unk2: u32, unk3: u32, fence_out: [*c]nvioctl_fence) Result;
pub extern fn nvioctlChannel_SetUserData(fd: u32, addr: ?*anyopaque) Result;
pub extern fn nvioctlChannel_Submit(fd: u32, cmdbufs: [*c]const nvioctl_cmdbuf, num_cmdbufs: u32, relocs: [*c]const nvioctl_reloc, reloc_shifts: [*c]const nvioctl_reloc_shift, num_relocs: u32, syncpt_incrs: [*c]const nvioctl_syncpt_incr, num_syncpt_incrs: u32, fences: [*c]nvioctl_fence, num_fences: u32) Result;
pub extern fn nvioctlChannel_GetSyncpt(fd: u32, module_id: u32, syncpt: [*c]u32) Result;
pub extern fn nvioctlChannel_GetModuleClockRate(fd: u32, module_id: u32, freq: [*c]u32) Result;
pub extern fn nvioctlChannel_SetModuleClockRate(fd: u32, module_id: u32, freq: u32) Result;
pub extern fn nvioctlChannel_MapCommandBuffer(fd: u32, maps: [*c]nvioctl_command_buffer_map, num_maps: u32, compressed: bool) Result;
pub extern fn nvioctlChannel_UnmapCommandBuffer(fd: u32, maps: [*c]const nvioctl_command_buffer_map, num_maps: u32, compressed: bool) Result;
pub extern fn nvioctlChannel_SetSubmitTimeout(fd: u32, timeout: u32) Result;

const thread_context = @import("../arm/thread_context.zig");
const BIT = @import("../types.zig").BIT;

const CUR_PROCESS_HANDLE = 0xFFFF8001;
const CUR_THREAD_HANDLE = 0xFFFF8000;
const MAX_WAIT_OBJECTS = 0x40;

pub const MemoryType = enum(u32) {
    MemType_Unmapped=0x00,            //< Unmapped memory.
    MemType_Io=0x01,                  //< Mapped by kernel capability parsing in \ref svcCreateProcess.
    MemType_Normal=0x02,              //< Mapped by kernel capability parsing in \ref svcCreateProcess.
    MemType_CodeStatic=0x03,          //< Mapped during \ref svcCreateProcess.
    MemType_CodeMutable=0x04,         //< Transition from MemType_CodeStatic performed by \ref svcSetProcessMemoryPermission.
    MemType_Heap=0x05,                //< Mapped using \ref svcSetHeapSize.
    MemType_SharedMem=0x06,           //< Mapped using \ref svcMapSharedMemory.
    MemType_WeirdMappedMem=0x07,      //< Mapped using \ref svcMapMemory.
    MemType_ModuleCodeStatic=0x08,    //< Mapped using \ref svcMapProcessCodeMemory.
    MemType_ModuleCodeMutable=0x09,   //< Transition from \ref MemType_ModuleCodeStatic performed by \ref svcSetProcessMemoryPermission.
    MemType_IpcBuffer0=0x0A,          //< IPC buffers with descriptor flags=0.
    MemType_MappedMemory=0x0B,        //< Mapped using \ref svcMapMemory.
    MemType_ThreadLocal=0x0C,         //< Mapped during \ref svcCreateThread.
    MemType_TransferMemIsolated=0x0D, //< Mapped using \ref svcMapTransferMemory when the owning process has perm=0.
    MemType_TransferMem=0x0E,         //< Mapped using \ref svcMapTransferMemory when the owning process has perm!=0.
    MemType_ProcessMem=0x0F,          //< Mapped using \ref svcMapProcessMemory.
    MemType_Reserved=0x10,            //< Reserved.
    MemType_IpcBuffer1=0x11,          //< IPC buffers with descriptor flags=1.
    MemType_IpcBuffer3=0x12,          //< IPC buffers with descriptor flags=3.
    MemType_KernelStack=0x13,         //< Mapped in kernel during \ref svcCreateThread.
    MemType_CodeReadOnly=0x14,        //< Mapped in kernel during \ref svcControlCodeMemory.
    MemType_CodeWritable=0x15,        //< Mapped in kernel during \ref svcControlCodeMemory.
    MemType_Coverage=0x16,            //< Not available.
    MemType_Insecure=0x17,            //< Mapped in kernel during \ref svcMapInsecurePhysicalMemory.
};

pub const MemoryState = enum(u32) {
    MemState_Type=0xFF,                             //< Type field (see \ref MemoryType).
    MemState_PermChangeAllowed=BIT(8),              //< Permission change allowed.
    MemState_ForceRwByDebugSyscalls=BIT(9),         //< Force read/writable by debug syscalls.
    MemState_IpcSendAllowed_Type0=BIT(10),          //< IPC type 0 send allowed.
    MemState_IpcSendAllowed_Type3=BIT(11),          //< IPC type 3 send allowed.
    MemState_IpcSendAllowed_Type1=BIT(12),          //< IPC type 1 send allowed.
    MemState_ProcessPermChangeAllowed=BIT(14),      //< Process permission change allowed.
    MemState_MapAllowed=BIT(15),                    //< Map allowed.
    MemState_UnmapProcessCodeMemAllowed=BIT(16),    //< Unmap process code memory allowed.
    MemState_TransferMemAllowed=BIT(17),            //< Transfer memory allowed.
    MemState_QueryPAddrAllowed=BIT(18),             //< Query physical address allowed.
    MemState_MapDeviceAllowed=BIT(19),              //< Map device allowed (\ref svcMapDeviceAddressSpace and \ref svcMapDeviceAddressSpaceByForce).
    MemState_MapDeviceAlignedAllowed=BIT(20),       //< Map device aligned allowed.
    MemState_IpcBufferAllowed=BIT(21),              //< IPC buffer allowed.
    MemState_IsPoolAllocated=BIT(22),               //< Is pool allocated.
    MemState_IsRefCounted=.MemState_IsPoolAllocated, //< Alias for \ref MemState_IsPoolAllocated.
    MemState_MapProcessAllowed=BIT(23),             //< Map process allowed.
    MemState_AttrChangeAllowed=BIT(24),             //< Attribute change allowed.
    MemState_CodeMemAllowed=BIT(25),                //< Code memory allowed.
};

pub const MemoryAttribute = enum(u32) {
    MemAttr_IsBorrowed=BIT(0),         //< Is borrowed memory.
    MemAttr_IsIpcMapped=BIT(1),        //< Is IPC mapped (when IpcRefCount > 0).
    MemAttr_IsDeviceMapped=BIT(2),     //< Is device mapped (when DeviceRefCount > 0).
    MemAttr_IsUncached=BIT(3),         //< Is uncached.
    MemAttr_IsPermissionLocked=BIT(4), //< Is permission locked.
};

pub const Permission = enum(u32) {
    Perm_None     = 0,                  //< No permissions.
    Perm_R        = BIT(0),             //< Read permission.
    Perm_W        = BIT(1),             //< Write permission.
    Perm_X        = BIT(2),             //< Execute permission.
    Perm_Rw       = .Perm_R | .Perm_W,  //< Read/write permissions.
    Perm_Rx       = .Perm_R | .Perm_X,  //< Read/execute permissions.
    Perm_DontCare = BIT(28),            //< Don't care
};

pub const MemoryInfo = extern struct {
    addr:            u64,           //< Base address.
    size:            u64,           //< Size.
    __type:          u32,           //< Memory type (see lower 8 bits of \ref MemoryState).
    attr:            u32,           //< Memory attributes (see \ref MemoryAttribute).
    perm:            u32,           //< Memory permissions (see \ref Permission).
    ipc_refcount:    u32,           //< IPC reference count.
    dev_refcount:    u32,           //< Device reference count.
    padding:         u32,           //< Padding.
};

pub const PhysicalMemoryInfo = extern struct {
    physical_addr:       u64,   //< Physical address.
    virtual_addr:        u64,   //< Virtual address.
    size:                u64    //< Size.
};


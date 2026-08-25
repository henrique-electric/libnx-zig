pub const _LOCK_T = u32;

/// Mutex datatype, defined in newlib.
pub const Mutex = _LOCK_T;

/// Recursive mutex datatype, defined in newlib.
pub const RMutex = _LOCK_RECURSIVE_T;


const _LOCK_RECURSIVE_T = extern struct {
    lock: _LOCK_T,
    thread_tag: u32,
    counter: u32
};

pub extern fn mutexLock(m: *Mutex) void;
pub extern fn mutexUnlock(m: *Mutex) void;
pub extern fn mutexTryLock(m: *Mutex) void;
pub extern fn mutexIsLockedByCurrentThread(m: *const Mutex) bool;
pub extern fn rmutexLock(m: *RMutex) void;
pub extern fn rmutexUnlock(m: *RMutex) void;
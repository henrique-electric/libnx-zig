# libnx.zig

Hand-ported Zig bindings for libnx —
[switchbrew/libnx](https://github.com/switchbrew/libnx)

## What this is

`extern fn` / type declarations, not a reimplementation. The real logic
(syscall trampolines, thread scheduling, buffer swapping, IPC to `vi`/`nvdrv`)
still lives in libnx's compiled C/ASM. This file just describes libnx's ABI
to Zig so you can link against a real, devkitA64-built `libnx.a` and call it
directly — e.g. `libnx.threadCreate(...)` from Zig runs libnx's actual
`threadCreate`.

The exceptions are the handful of things that were `static inline` in the
original C headers too (`MAKERESULT`, `mutexInit`, `BIT`, ...) — those are
ported as real (tiny) Zig code, same as they were real (tiny) C code.

## ⚠ ABI risk — read before relying on stack/global instances

A few libnx structs are **caller-allocated** (libnx writes into storage
*you* provide, rather than heap-allocating it for you) and embed
internal/newlib fields whose exact size depends on your devkitA64/newlib
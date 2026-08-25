# libnx.zig

Hand-ported Zig bindings for libnx —
[switchbrew/libnx](https://github.com/switchbrew/libnx) — split across two files:

- [libnx.zig](libnx.zig) — **Core** (types, Result, kernel sync primitives,
  a `svc.h` subset) and **Graphics** (native window, framebuffer, `vi`, minimal
  `nvidia`).
- [services.zig](services.zig) — **HID** (modern Npad/touch input) and
  **applet/system** (`am`, `apm`, `set`/`setsys`, `pctl`). Imports
  `libnx.zig` for shared types (`Result`, etc.) — keep both files together.

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

## Scope

- **Core**: and all inside kernel, the basis for input management and applet
- **Graphics**: Nvidia functions and structures

## ⚠ ABI risk — read before relying on stack/global instances

A few libnx structs are **caller-allocated** (libnx writes into storage
*you* provide, rather than heap-allocating it for you) and embed
internal/newlib fields whose exact size depends on your devkitA64/newlib
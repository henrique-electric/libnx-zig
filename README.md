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

## Setup
Just copy the **libnx-zig** directory at the root of the project or at whatever
you want. There's also an example build.zig for building a project using devkitpro
toolchain.

## Credits

Every declaration under `libnx-zig/` is ported from a specific C header in
[switchbrew/libnx](https://github.com/switchbrew/libnx) (mirrored here under
[`libnx/include`](libnx/include) for reference). Each `.zig` file carries a
`//!` header naming the upstream header and its original `@author`(s), e.g.:

```zig
//! Zig port of libnx's `switch/sf/hipc.h` ("Horizon Inter-Process Communication protocol").
//! Original author(s): fincs, SciresM.
//! Copyright (c) 2017-2018 libnx Authors. Licensed under the ISC License
//! (switchbrew/libnx) -- see /LICENSE-libnx.md at the repo root.
```

See [LICENSE-libnx.md](LICENSE-libnx.md) for the full upstream license text
and the consolidated list of credited authors.
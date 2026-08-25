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

- **Core**: `types.h`, `result.h`, and `kernel/{mutex,condvar,rwlock,
  semaphore,event,uevent,utimer,wait,thread,virtmem}.h`, plus a common
  subset of `kernel/svc.h` (~30 of the ~90 syscalls — the ones nearly every
  homebrew program touches: memory, threads, sync primitives, IPC handles,
  basic info/debug).
- **Graphics**: `display/{native_window,framebuffer}.h`, a common subset of
  `services/vi.h`, and the minimal `nvidia/nvmap.h` needed to back a
  framebuffer with GPU-visible memory.

Not ported: deko3d, the rest of `svc.h`, and the full auto-generated
result-module/description tables (both are large mechanical lists upstream —
add them the same mechanical way if you need them).

- **HID** (`services.zig`): the modern Npad API (`PadState`,
  `padConfigureInput`/`padUpdate`/`padGetButtons`/...) plus basic
  touchscreen. Legacy `hidScanInput()`/`HidControllerID` is deprecated
  upstream and intentionally not ported; keyboard/mouse/motion/vibration are
  omitted.
- **Applet & system** (`services.zig`): `am.h` (type/focus/operation-mode,
  the hook system, `appletMainLoop()`, exit locking — not applet
  *launching*), `apm.h` (performance/CPU-boost mode), `set.h`/`setsys.h`
  (firmware version, system language — not the rest of setsys's huge
  settings surface), and a minimal, low-confidence `pctl.h` sketch (see the
  warning in that file — this is the one section that's more "starting
  point to verify" than "port").

## ⚠ ABI risk — read before relying on stack/global instances

A few libnx structs are **caller-allocated** (libnx writes into storage
*you* provide, rather than heap-allocating it for you) and embed
internal/newlib fields whose exact size depends on your devkitA64/newlib
version:

- `Framebuffer`, `ViDisplay`, `ViLayer`, `UEvent`, `UTimer`, `NvMap` —
  embed internal bookkeeping fields
- `PadState`, `HidTouchScreenState` (in `services.zig`) — same story:
  internal sensor/timer bookkeeping and an unverified touch-array capacity

`Thread` **used to be on this list** but is now pinned by a `comptime`
assert (`@sizeOf(Thread) == 56`) after a user verified `sizeof(Thread)`
against a real devkitA64 toolchain — it turned out not to embed a newlib
`struct _reent` or a `tls_array` pointer the way the original guess assumed.
That number is snapshotted from one toolchain, not a documented constant, so
if you're on a different/updated devkitA64 and the file fails to compile on
that assert, re-check `sizeof(Thread)` on your setup and adjust the struct
and the assert to match — see the comment above `Thread` in
[libnx.zig](libnx.zig) for the exact re-verification steps. This is the
general pattern for resolving anything else in this list too: check the real
size, fix the struct, add the assert.

Each remaining one is marked `ABI-UNCERTAIN` in [libnx.zig](libnx.zig) / [services.zig](services.zig) with a
generously-sized `_reserved` pad standing in for the part of the layout that
couldn't be reconstructed exactly from memory for this port. If the real
struct turns out larger than this Zig version, libnx will write past the end
of it and silently corrupt whatever's next in memory — a bug that surfaces
far from its actual cause.

**Before trusting a stack/global instance of one of these types**, verify
`sizeof(T)` against your actual toolchain, e.g.:

```c
// compiled with devkitA64
#include <switch.h>
#include <stdio.h>
int main(void) { printf("%zu\n", sizeof(Thread)); }
```

and pad `_reserved` to match. Until you've done that, it's safer to allocate
the backing storage from C and only touch it from Zig via a pointer.

`NWindow` sidesteps this entirely: it's modeled as fully `opaque` because
idiomatic libnx code never allocates one directly — you only ever get a
`*NWindow` back from `nwindowGetDefault()` and pass it around by pointer.
`nwindowCreate` (for manual/extra layers, which *does* take caller-allocated
storage) is intentionally left out for the same reason as `Thread`.

A couple of function **signatures** are also flagged best-effort in comments
(`viCreateManagedLayer`, `nvMapCreate`) — argument order/count for these has
shifted across libnx versions in ways I couldn't pin down precisely from
memory; verify against your version's headers before relying on them.

Everything else in the file (the sync primitives, `Result` encoding, the
svc subset, pixel formats, etc.) is high-confidence and stable across libnx
versions.

## Using it

This targets libnx's real ABI: AArch64, devkitA64/newlib, standard GCC
struct layout (Zig's `extern struct` already follows the platform C ABI, so
what matters is field order/types matching, which is what's ported here).

In your `build.zig`, compile for an aarch64 target and link the real
`libnx.a` (and whatever else that build of libnx.a expects, e.g.
`libnvctrl.a`) — this file supplies no symbols on its own, it only describes
them.

`callconv(.c)` in `ThreadFunc`/`VoidFn` is Zig 0.16's spelling for the
platform C calling convention; adjust it if you're pinned to an older Zig.

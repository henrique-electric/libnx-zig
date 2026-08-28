# libnx License

The files under [`libnx-zig/`](libnx-zig/) are a hand-written Zig port of the
`extern` declarations found in [switchbrew/libnx](https://github.com/switchbrew/libnx)'s
C headers (see [`libnx/include`](libnx/include)). No compiled libnx code or
source text is redistributed here — only type/function signatures translated
to Zig syntax — but the declarations themselves, and the original `@author`
attributions, originate from libnx. Each ported `.zig` file carries a `//!`
header naming the upstream C header and author(s) it was ported from.

The original libnx source is distributed under the following license
(reproduced verbatim from [`LICENSE.md`](https://github.com/switchbrew/libnx/blob/master/LICENSE.md)
in the upstream repository):

```
Copyright 2017-2018 libnx Authors

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

## Per-file authors credited by this port

Names below are the `@author` tags found in the specific libnx headers this
project ports declarations from (not the full libnx contributor list):

- fincs
- plutoo
- TuxSH
- yellows8
- WinterMute
- ndeadly
- SciresM

Full credits for libnx as a whole belong to the switchbrew/libnx Authors —
see the [libnx repository](https://github.com/switchbrew/libnx) and its
[Changelog.md](https://github.com/switchbrew/libnx/blob/master/Changelog.md)
for the complete contributor history.

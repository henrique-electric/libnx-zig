const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});

    const target = b.resolveTargetQuery(.{
        .cpu_arch = .aarch64,
        .cpu_model = .{ .explicit = &std.Target.aarch64.cpu.cortex_a57 },
        .os_tag = .freestanding,
        .abi = .none,
    });

    // --- Step 1: compile the Zig sources down to a relocatable object file ---
    const obj = b.addObject(.{
        .name = "main",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .root_source_file = b.path("main.zig"),
            .pic = true,
        }),
    });

    // --- Step 2: link that object against libnx using devkitA64's gcc ---
    const devkitpro = b.graph.environ_map.get("DEVKITPRO") orelse {
        std.debug.print(
            "DEVKITPRO is not set - install devkitPro and export DEVKITPRO in your environment\n",
            .{},
        );
        std.process.exit(1);
    };

    const exe_suffix = if (builtin.target.os.tag == .windows) ".exe" else "";
    const gcc_path = b.fmt("{s}/devkitA64/bin/aarch64-none-elf-gcc{s}", .{ devkitpro, exe_suffix });
    const libnx_dir = b.fmt("{s}/libnx", .{devkitpro});
    const specs_path = b.fmt("{s}/switch.specs", .{libnx_dir});
    const libnx_lib_dir = b.fmt("{s}/lib", .{libnx_dir});
    const portlibs_lib_dir = b.fmt("{s}/portlibs/switch/lib", .{devkitpro});

    const link_step = b.addSystemCommand(&.{gcc_path});
    link_step.addArgs(&.{
        b.fmt("-specs={s}", .{specs_path}),
        "-march=armv8-a+crc+crypto",
        "-mtune=cortex-a57",
        "-mtp=soft",
        "-fPIE",
        "-g",
    });
    link_step.addArtifactArg(obj);
    link_step.addArgs(&.{
        b.fmt("-L{s}", .{libnx_lib_dir}),
        b.fmt("-L{s}", .{portlibs_lib_dir}),
        "-lnx",
        "-o",
    });
    const elf_file = link_step.addOutputFileArg("main.elf");

    const install_elf = b.addInstallFile(elf_file, "main.elf");
    b.getInstallStep().dependOn(&install_elf.step);

    // --- Step 3: build the .nacp metadata and pack the .elf into a .nro ---
    const tools_dir = b.fmt("{s}/tools/bin", .{devkitpro});
    const nacptool_path = b.fmt("{s}/nacptool{s}", .{ tools_dir, exe_suffix });
    const elf2nro_path = b.fmt("{s}/elf2nro{s}", .{ tools_dir, exe_suffix });
    const default_icon = b.fmt("{s}/default_icon.jpg", .{libnx_dir});

    const nacp_step = b.addSystemCommand(&.{nacptool_path});
    nacp_step.addArgs(&.{ "--create", "libnx-zig", "Unspecified Author", "1.0.0" });
    const nacp_file = nacp_step.addOutputFileArg("main.nacp");

    const nro_step = b.addSystemCommand(&.{elf2nro_path});
    nro_step.addFileArg(elf_file);
    const nro_file = nro_step.addOutputFileArg("main.nro");
    nro_step.addArg(b.fmt("--icon={s}", .{default_icon}));
    nro_step.addPrefixedFileArg("--nacp=", nacp_file);

    const install_nro = b.addInstallFile(nro_file, "main.nro");
    b.getInstallStep().dependOn(&install_nro.step);
}

const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .thumb, //
        .os_tag = .freestanding,
        .abi = .eabihf,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m4 },
        .cpu_features_add = std.Target.arm.featureSet(&[_]std.Target.arm.Feature{std.Target.arm.Feature.v7em})
    });

    const optimize = b.standardOptimizeOption(.{});

    const elf = b.addExecutable(.{
        .name = "firmware.elf",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = false,
        .linkage = .static,
        .single_threaded = true,
    });

    elf.setLinkerScript(b.path("linkerscript.ld"));
    elf.addLibraryPath(.{ .cwd_relative = "/usr/arm-none-eabi/lib" });
    elf.addLibraryPath(.{ .cwd_relative =  "/usr/lib/gcc/arm-none-eabi/13.2.0/thumb/v7e-m+fp/hard/" });
    elf.link_gc_sections = true;
    elf.link_function_sections = true;
    elf.link_data_sections = true;


    const elf_install = b.addInstallArtifact(elf, .{});

    const bin = b.addObjCopy(elf.getEmittedBin(), .{ .format = .bin });
    const bin_install = b.addInstallBinFile(bin.getOutput(), "firmware.bin");

    bin_install.step.dependOn(&elf_install.step);

    b.default_step.dependOn(&bin_install.step);


    const remote_debug = b.addSystemCommand(&.{
        "openocd","-f", "/usr/share/openocd/scripts/interface/stlink-v2.cfg", "-f", "/usr/share/openocd/scripts/target/stm32f4x.cfg",
    });

    b.step("debug", "Start OpenOCD GDB server on port :3333").dependOn(&remote_debug.step);


    const flash = b.addSystemCommand(&.{
        "st-flash", "--reset", "write", "zig-out/bin/firmware.bin", "0x8000000"
    });

    b.step("flash", "Flash firmware").dependOn(&flash.step);

    const dump = b.addSystemCommand(&.{ "llvm-objdump", "-D", "zig-out/bin/firmware.elf" });

    b.step("dump", "Dump Object File").dependOn(&dump.step);


    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
}

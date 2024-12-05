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

    const shared_lib = b.addModule("shared", .{ 
        .root_source_file = b.path("shared/shared.zig"),
        .target = target,
        .optimize = optimize
    });


    const bootloader = b.addExecutable(.{
        .name = "bootloader.elf",
        .root_source_file = b.path("bootloader/src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = false,
        .linkage = .static,
        .single_threaded = true,
    });


    bootloader.root_module.addImport("shared", shared_lib);
    bootloader.setLinkerScript(b.path("bootloader/linkerscript.ld"));
    bootloader.addLibraryPath(.{ .cwd_relative = "/usr/arm-none-eabi/lib" });
    bootloader.addLibraryPath(.{ .cwd_relative =  "/usr/lib/gcc/arm-none-eabi/13.2.0/thumb/v7e-m+fp/hard/" });
    // bootloader.link_gc_sections = true;
    // bootloader.link_function_sections = true;
    // bootloader.link_data_sections = true;


    b.installArtifact(bootloader);
    const copy_bin = b.addObjCopy(bootloader.getEmittedBin(), .{ .format = .bin, });
    copy_bin.step.dependOn(&bootloader.step);
    b.default_step.dependOn(&copy_bin.step);

    const bootloader_module = b.createModule(.{ .root_source_file = copy_bin.getOutput() });

    // Firmware Section

    const firmware = b.addExecutable(.{
        .name = "firmware.elf",
        .root_source_file = b.path("app/src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = false,
        .linkage = .static,
        .single_threaded = true,
    });

    
    firmware.root_module.addImport("shared", shared_lib);
    firmware.root_module.addImport("bootloader", bootloader_module);
    firmware.setLinkerScript(b.path("app/linkerscript.ld"));
    firmware.addLibraryPath(.{ .cwd_relative = "/usr/arm-none-eabi/lib" });
    firmware.addLibraryPath(.{ .cwd_relative =  "/usr/lib/gcc/arm-none-eabi/13.2.0/thumb/v7e-m+fp/hard/" });
    firmware.link_gc_sections = true;
    firmware.link_function_sections = true;
    firmware.link_data_sections = true;


    const firmware_elf_install = b.addInstallArtifact(firmware, .{});

    const firmware_bin = b.addObjCopy(firmware.getEmittedBin(), .{ .format = .bin });
    const firmware_bin_install = b.addInstallBinFile(firmware_bin.getOutput(), "firmware.bin");

    firmware_bin_install.step.dependOn(&firmware_elf_install.step);


    b.default_step.dependOn(&firmware_bin_install.step);

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

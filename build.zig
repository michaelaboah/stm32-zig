const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    var target = b.resolveTargetQuery(.{
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
    bootloader.link_gc_sections = true;
    bootloader.link_function_sections = true;
    bootloader.link_data_sections = true;


    b.installArtifact(bootloader);
    const copy_bin = b.addObjCopy(bootloader.getEmittedBin(), .{ .format = .bin, .pad_to = 0x8000 });
    const bootloader_bin_install = b.addInstallBinFile(copy_bin.getOutput(), "bootloader.bin");
    copy_bin.step.dependOn(&bootloader.step);
    b.default_step.dependOn(&copy_bin.step);


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
    firmware.setLinkerScript(b.path("app/linkerscript.ld"));
    firmware.addLibraryPath(.{ .cwd_relative = "/usr/arm-none-eabi/lib" });
    firmware.addLibraryPath(.{ .cwd_relative =  "/usr/lib/gcc/arm-none-eabi/13.2.0/thumb/v7e-m+fp/hard/" });
    firmware.link_gc_sections = true;
    firmware.link_function_sections = true;
    firmware.link_data_sections = true;


    const firmware_elf_install = b.addInstallArtifact(firmware, .{});

    firmware_elf_install.step.dependOn(&bootloader_bin_install.step);

    const firmware_bin = b.addObjCopy(firmware.getEmittedBin(), .{ .format = .bin });
    const firmware_bin_install = b.addInstallBinFile(firmware_bin.getOutput(), "firmware.bin");

    firmware_bin_install.step.dependOn(&firmware_elf_install.step);


    b.default_step.dependOn(&firmware_bin_install.step);

    const remote_debug = b.addSystemCommand(&.{
        "openocd","-f", "/usr/share/openocd/scripts/interface/stlink-v2.cfg", "-f", "/usr/share/openocd/scripts/target/stm32f4x.cfg",
    });

    b.step("debug", "Start OpenOCD GDB server on port :3333").dependOn(&remote_debug.step);


    const flash = b.addSystemCommand(&.{
        "sudo", "st-flash", "--reset", "write", "zig-out/bin/firmware.bin", "0x8000000"
    });

    flash.step.dependOn(b.default_step);
    b.step("flash", "Flash firmware").dependOn(&flash.step);

    const dump = b.addSystemCommand(&.{ "llvm-objdump", "-D", "zig-out/bin/firmware.elf" });

    b.step("dump", "Dump Object File").dependOn(&dump.step);

    target = b.standardTargetOptions(.{});


    const shared_static_lib = b.addStaticLibrary(.{ 
        .name = "shared",
        .root_source_file = b.path("shared/shared.zig"),
        .target = target,
        .optimize = optimize
    });

    b.installArtifact(shared_static_lib);

    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("shared/core/ringbuffer.zig"),
        .target = target,
        .optimize = optimize
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("shared/core/ringbuffer.zig"),
        .target = target,
        .optimize = optimize
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);


    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);


    const updater_exe = b.addExecutable(.{
        .name = "updater",
        .target = b.resolveTargetQuery(.{}),
        .root_source_file = b.path("tools/updater.zig"),
    });

    const serial = b.dependency("serial", .{
        // .root_source_file = b.path("dependencies/serial/src/serial.zig"),
        // .target = b.resolveTargetQuery(.{}),
        // .optimize = .Debug,
    });

    updater_exe.root_module.addImport("serial", serial.module("serial"));
    // updater_exe.addIn

    b.installArtifact(updater_exe);

    const run_updater = b.addRunArtifact(updater_exe);

    const run_updater_step = b.step("update", "Update the firmware");
    run_updater_step.dependOn(&run_updater.step);
}

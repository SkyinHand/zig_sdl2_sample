const std = @import("std");

// Build is generally a directed acyclic graph composed of dependencies.
pub fn build(b: *std.Build) void {
    // For standardization, two functions are provided: `standardTargetOptions`, `standardOptimizeOption`
    // `standardTargetOptions`: Set the operating system where the generated file is located at runtime, such as windows, linux, etc.
    // `standardOptimizeOption`: Set the release or debug type of the generated file.
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "sdl2",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.addIncludePath(.{ .cwd_relative = "D:/SDK/SDL2/include" });
    // Load the static library and dynamic library into the system library.
    exe.addLibraryPath(.{ .cwd_relative = "D:/SDK/SDL2/lib" });
    exe.addLibraryPath(.{ .cwd_relative = "D:/SDK/SDL2/bin" });

    // Link the system library files inside.
    exe.linkSystemLibrary("SDL2");
    exe.linkSystemLibrary("SDL2_mixer");

    // We need the contents of the C standard library, so we need to connect the C library.
    exe.linkLibC();

    // Because the absolute path cannot be set by directly using installBinFile,
    // the addInstallBinFile method is used instead, and the dependencies are set.
    // When it is finally built, the required dependencies will be found up and built one by one.
    const sdl2_mv_step = b.addInstallBinFile(.{ .cwd_relative = "D:/SDK/SDL2/bin/SDL2.dll" }, "SDL2.dll");
    b.getInstallStep().dependOn(&sdl2_mv_step.step);
    const sdl2_mixer_step = b.addInstallBinFile(.{ .cwd_relative = "D:/SDK/SDL2/bin/SDL2_mixer.dll" }, "SDL2_mixer.dll");
    b.getInstallStep().dependOn(&sdl2_mixer_step.step);

    b.installArtifact(exe);

    // This will create a run step in the Build diagram, which will be executed
    // when other steps depend on this step.
    // The following code will establish one of the above dependencies.
    const run_cmd = b.addRunArtifact(exe);

    // The following are the original contents of the template.
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}

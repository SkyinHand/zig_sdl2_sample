const std = @import("std");

// Build总的来说是一个由依赖组成的有向无环图
// 从主文件开始
pub fn build(b: *std.Build) void {
    // 为了标准化，提供了两个函数：standardTargetOptions、standardOptimizeOption
    // standardTargetOptions: 设置生成文件在运行时所在的操作系统，如windows，linux等
    // standardOptimizeOption：设置生成文件的release或者debug类型
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "sdl2",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // 由于直接使用installBinFile无法设定绝对路径，所以改用addInstallBinFile方法，并且设置依赖，等到最后构建的时候，会向上查找所需依赖项并逐个构建
    const sdl2_mv_step = b.addInstallBinFile(.{ .cwd_relative = "D:/SDK/SDL2/bin/SDL2.dll" }, "SDL2.dll");
    b.getInstallStep().dependOn(&sdl2_mv_step.step);
    exe.addIncludePath(.{ .cwd_relative = "D:/SDK/SDL2/include" });
    exe.addLibraryPath(.{ .cwd_relative = "D:/SDK/SDL2/lib" });
    // Add the folder where SDL2 is located to the environment variable.
    exe.linkSystemLibrary("SDL2");
    exe.linkLibC();

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.

    // 这个会在Build图中创建一个运行步骤，当其他步骤依赖此步骤的时候，这个步骤将会被执行
    // 下面的一段代码将会建立上述的一个依赖
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
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

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}

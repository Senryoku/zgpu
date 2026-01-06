const std = @import("std");
const log = std.log.scoped(.zgpu);

const webgpu_dawn = @import("webgpu_dawn");

const default_options = struct {
    const uniforms_buffer_size = 4 * 1024 * 1024;
    const dawn_skip_validation = false;
    const dawn_allow_unsafe_apis = false;
    const buffer_pool_size = 256;
    const texture_pool_size = 256;
    const texture_view_pool_size = 256;
    const sampler_pool_size = 16;
    const render_pipeline_pool_size = 128;
    const compute_pipeline_pool_size = 128;
    const bind_group_pool_size = 32;
    const bind_group_layout_pool_size = 32;
    const pipeline_layout_pool_size = 32;
    const max_num_bindings_per_group = 10;
    const max_num_bind_groups_per_pipeline = 4;
};

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const options = .{
        .uniforms_buffer_size = b.option(
            u64,
            "uniforms_buffer_size",
            "Set uniforms buffer size",
        ) orelse default_options.uniforms_buffer_size,
        .dawn_skip_validation = b.option(
            bool,
            "dawn_skip_validation",
            "Disable Dawn validation",
        ) orelse default_options.dawn_skip_validation,
        .dawn_allow_unsafe_apis = b.option(
            bool,
            "dawn_allow_unsafe_apis",
            "Allow unsafe WebGPU APIs (e.g. timestamp queries)",
        ) orelse default_options.dawn_allow_unsafe_apis,
        .buffer_pool_size = b.option(
            u32,
            "buffer_pool_size",
            "Set buffer pool size",
        ) orelse default_options.buffer_pool_size,
        .texture_pool_size = b.option(
            u32,
            "texture_pool_size",
            "Set texture pool size",
        ) orelse default_options.texture_pool_size,
        .texture_view_pool_size = b.option(
            u32,
            "texture_view_pool_size",
            "Set texture view pool size",
        ) orelse default_options.texture_view_pool_size,
        .sampler_pool_size = b.option(
            u32,
            "sampler_pool_size",
            "Set sample pool size",
        ) orelse default_options.sampler_pool_size,
        .render_pipeline_pool_size = b.option(
            u32,
            "render_pipeline_pool_size",
            "Set render pipeline pool size",
        ) orelse default_options.render_pipeline_pool_size,
        .compute_pipeline_pool_size = b.option(
            u32,
            "compute_pipeline_pool_size",
            "Set compute pipeline pool size",
        ) orelse default_options.compute_pipeline_pool_size,
        .bind_group_pool_size = b.option(
            u32,
            "bind_group_pool_size",
            "Set bind group pool size",
        ) orelse default_options.bind_group_pool_size,
        .bind_group_layout_pool_size = b.option(
            u32,
            "bind_group_layout_pool_size",
            "Set bind group layout pool size",
        ) orelse default_options.bind_group_layout_pool_size,
        .pipeline_layout_pool_size = b.option(
            u32,
            "pipeline_layout_pool_size",
            "Set pipeline layout pool size",
        ) orelse default_options.pipeline_layout_pool_size,
        .max_num_bindings_per_group = b.option(
            u32,
            "max_num_bindings_per_group",
            "Set maximum number of bindings per bind group",
        ) orelse default_options.max_num_bindings_per_group,
        .max_num_bind_groups_per_pipeline = b.option(
            u32,
            "max_num_bind_groups_per_pipeline",
            "Set maximum number of bindings groups per pipeline",
        ) orelse default_options.max_num_bind_groups_per_pipeline,
    };

    const options_step = b.addOptions();
    inline for (std.meta.fields(@TypeOf(options))) |field| {
        options_step.addOption(field.type, field.name, @field(options, field.name));
    }

    const options_module = options_step.createModule();

    const root = b.addModule("root", .{
        .root_source_file = b.path("src/zgpu.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "zgpu_options", .module = options_module },
            .{ .name = "zpool", .module = b.dependency("zpool", .{}).module("root") },
        },
    });

    const zdawn = b.addLibrary(.{
        .name = "zdawn",
        .use_llvm = true,
        .root_module = root,
    });
    b.installArtifact(zdawn);
    linkSystemDeps(b, zdawn);
    try addLibraryPathsTo(b, zdawn);

    // try webgpu_dawn.link(b, "webgpu_dawn", zdawn.root_module);
    zdawn.linkLibC();
    zdawn.linkLibCpp();
    zdawn.addIncludePath(b.path("src"));
    zdawn.addIncludePath(b.path("include"));

    const test_step = b.step("test", "Run zgpu tests");
    const tests = b.addTest(.{
        .name = "zgpu-tests",
        .use_llvm = true,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/zgpu.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    tests.addIncludePath(b.path("include"));
    linkSystemDeps(b, tests);
    try addLibraryPathsTo(b, tests);
    b.installArtifact(tests);
    test_step.dependOn(&b.addRunArtifact(tests).step);
}

/// Call this for your exe to copy dxcompiler.dll and dxil.dll to your exe's directory from a dependency (pass the zgpu dependency name to use the included dlls)
pub fn installDxcFrom(exe: *std.Build.Step.Compile, dep_name: []const u8) void {
    const b = exe.step.owner;
    exe.step.dependOn(
        &b.addInstallFileWithDir(
            .{ .dependency = .{
                .dependency = b.dependency(dep_name, .{}),
                .sub_path = "bin/x64/dxcompiler.dll",
            } },
            .bin,
            "dxcompiler.dll",
        ).step,
    );
    exe.step.dependOn(
        &b.addInstallFileWithDir(
            .{ .dependency = .{
                .dependency = b.dependency(dep_name, .{}),
                .sub_path = "bin/x64/dxil.dll",
            } },
            .bin,
            "dxil.dll",
        ).step,
    );
}

pub fn linkSystemDeps(b: *std.Build, compile_step: *std.Build.Step.Compile) void {
    switch (compile_step.rootModuleTarget().os.tag) {
        .windows => {
            if (b.lazyDependency("system_sdk", .{})) |system_sdk| {
                compile_step.addLibraryPath(system_sdk.path("windows/lib/x86_64-windows-gnu"));
            }
            compile_step.linkSystemLibrary("ole32");
            compile_step.linkSystemLibrary("oleaut32");
            compile_step.linkSystemLibrary("dxguid");
            compile_step.linkSystemLibrary("dbghelp");
        },
        .macos => {
            if (b.lazyDependency("system_sdk", .{})) |system_sdk| {
                compile_step.addLibraryPath(system_sdk.path("macos12/usr/lib"));
                compile_step.addFrameworkPath(system_sdk.path("macos12/System/Library/Frameworks"));
            }
            compile_step.linkSystemLibrary("objc");
            compile_step.linkFramework("Metal");
            compile_step.linkFramework("CoreGraphics");
            compile_step.linkFramework("Foundation");
            compile_step.linkFramework("IOKit");
            compile_step.linkFramework("IOSurface");
            compile_step.linkFramework("QuartzCore");
        },
        else => {},
    }
}

pub fn addLibraryPathsTo(b: *std.Build, compile_step: *std.Build.Step.Compile) !void {
    const dawn = b.dependency("webgpu_dawn", .{});
    compile_step.addLibraryPath(dawn.path("./build/src/dawn/native"));
}

pub fn checkTargetSupported(target: std.Target) bool {
    const supported = switch (target.os.tag) {
        .windows => target.cpu.arch.isX86() and target.abi.isGnu(),
        .linux => (target.cpu.arch.isX86() or target.cpu.arch.isAARCH64()) and target.abi.isGnu(),
        .macos => blk: {
            if (!target.cpu.arch.isX86() and !target.cpu.arch.isAARCH64()) break :blk false;

            // If min. target macOS version is lesser than the min version we have available, then
            // our Dawn binary is incompatible with the target.
            if (target.os.version_range.semver.min.order(
                .{ .major = 12, .minor = 0, .patch = 0 },
            ) == .lt) break :blk false;
            break :blk true;
        },
        else => false,
    };
    if (supported == false) {
        log.warn("\n" ++
            \\---------------------------------------------------------------------------
            \\
            \\Dawn/WebGPU binary for this target is not available.
            \\
            \\Following targets are supported:
            \\
            \\x86_64-windows-gnu
            \\x86_64-linux-gnu
            \\x86_64-macos.12.0.0-none
            \\aarch64-linux-gnu
            \\aarch64-macos.12.0.0-none
            \\
            \\---------------------------------------------------------------------------
            \\
        , .{});
    }
    return supported;
}

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const linkage = b.option(std.builtin.LinkMode, "linkage", "Linkage type for the library") orelse .static;

    const bzip2_dep = b.dependency("bzip2", .{});

    const flags = .{""};

    const bz2 = b.addLibrary(.{
        .name = "bz2",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
        .linkage = linkage,
    });
    bz2.root_module.addCSourceFiles(.{
        .root = bzip2_dep.path("."),
        .files = &bz2_sources,
        .flags = &flags,
    });
    bz2.installHeader(bzip2_dep.path("bzlib.h"), "bzlib.h");
    b.installArtifact(bz2);

    const bzip2 = b.addExecutable(.{
        .name = "bzip2",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    bzip2.root_module.linkLibrary(bz2);
    bzip2.root_module.addCSourceFile(.{
        .file = bzip2_dep.path("bzip2.c"),
        .flags = &flags,
    });
    b.installArtifact(bzip2);

    const bzip2recover = b.addExecutable(.{
        .name = "bzip2recover",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    bzip2recover.root_module.linkLibrary(bz2);
    bzip2recover.root_module.addCSourceFile(.{
        .file = bzip2_dep.path("bzip2recover.c"),
        .flags = &flags,
    });
    b.installArtifact(bzip2recover);
}

const bz2_sources = .{
    "blocksort.c",
    "huffman.c",
    "crctable.c",
    "randtable.c",
    "compress.c",
    "decompress.c",
    "bzlib.c",
};

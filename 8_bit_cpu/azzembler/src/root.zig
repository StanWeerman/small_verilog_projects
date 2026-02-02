const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Assembler = struct {
    const Self = @This();
    const cwd = std.fs.cwd();

    allocator: Allocator,

    asm_file: std.fs.File,
    bin_file: std.fs.File,
    v_file: std.fs.File,

    pub fn init(allocator: Allocator, file_path: [*:0]u8) !Self {
        cwd.deleteTree("build") catch |err| {
            std.debug.print("Error: {any}\n", .{err});
            // if (err == std.fs.Dir.DeleteTreeError)
        };

        try cwd.makeDir("build");

        const asm_path: [:0]const u8 = std.mem.span(file_path);
        const bin_path = try std.fs.path.join(allocator, &[_][]const u8{ "build/", std.fs.path.replaceExt(allocator, std.fs.path.basename(asm_path), ".bin") });
        const v_path = try std.fs.path.join(allocator, &[_][]const u8{ "build/", std.fs.path.replaceExt(allocator, std.fs.path.basename(asm_path), ".v") });

        const asm_file = try cwd.openFile(asm_path, .{ .mode = .read_only });
        const bin_file = try cwd.openFile(bin_path, .{ .mode = .read_only });
        const v_file = try cwd.openFile(v_path, .{ .mode = .read_only });

        std.debug.print("Assembling {s}\n", .{asm_file});
        allocator.free(bin_path);
        allocator.free(v_path);

        return Self{
            .allocator = allocator,
            .asm_file = asm_file,
            .bin_file = bin_file,
            .v_file = v_file,
        };
    }

    pub fn deinit(self: *Self) void {
        self.asm_file.close();
        self.bin_file.close();
        self.v_file.close();
    }

    pub fn assemble(self: *Self) void {
        _ = self;
    }
};

pub fn bufferedPrint() !void {
    // Stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try stdout.flush(); // Don't forget to flush!
}

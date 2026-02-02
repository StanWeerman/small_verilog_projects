const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Assembler = struct {
    const Self = @This();
    const cwd = std.fs.cwd();

    const AssemblerError = error{
        BadCommandLine,
        FileNotFound,
    };

    const Flags = struct {
        v: bool,
        d: bool,
    };

    allocator: Allocator,

    asm_file: std.fs.File,
    bin_file: std.fs.File,
    v_file: std.fs.File,

    flags: Flags,

    pub fn init(allocator: Allocator, argv: [][*:0]u8) !Self {
        const count = std.os.argv.len;

        if (count != 2 and count != 3) {
            return AssemblerError.BadCommandLine;
        } else {
            std.debug.print("Usage: azzembler program.s\n", .{});
        }
        var flags: Flags = .{ .v = false, .d = false };
        if (count > 2 and count < 5) {
            for (argv[2..]) |flag_str| {
                const flag: [:0]const u8 = std.mem.span(flag_str);
                if (std.mem.eql(u8, "-v", flag)) {
                    flags.v = true;
                } else if (std.mem.eql(u8, "-d", flag)) {
                    flags.d = true;
                } else {
                    return AssemblerError.BadCommandLine;
                }
            }
        }
        cwd.deleteTree("build") catch |err| {
            if (flags.d) {
                std.debug.print("Error: {any}\n", .{err});
            }
        };

        try cwd.makeDir("build");

        const asm_path: [:0]const u8 = std.mem.span(argv[1]);
        const base = std.fs.path.stem(std.fs.path.basename(asm_path));

        const bin_base = try std.mem.concat(allocator, u8, &.{ base, ".bin" });
        defer allocator.free(bin_base);
        const bin_path = try std.fs.path.join(allocator, &[_][]const u8{ "build/", bin_base });
        defer allocator.free(bin_path);
        const v_base = try std.mem.concat(allocator, u8, &.{ base, ".v" });
        defer allocator.free(v_base);
        const v_path = try std.fs.path.join(allocator, &[_][]const u8{ "build/", v_base });
        defer allocator.free(v_path);

        const asm_file = try cwd.openFile(asm_path, .{ .mode = .read_only });
        const bin_file = try cwd.createFile(bin_path, .{});
        const v_file = try cwd.createFile(v_path, .{});

        if (flags.d) {
            std.debug.print("Assembling {s}\n", .{asm_path});
            std.debug.print("Writing to {s}\n", .{bin_path});
            std.debug.print("Writing to {s}\n", .{v_path});
        }

        return Self{
            .allocator = allocator,
            .asm_file = asm_file,
            .bin_file = bin_file,
            .v_file = v_file,
            .flags = flags,
        };
    }

    pub fn deinit(self: *const Self) void {
        self.asm_file.close();
        self.bin_file.close();
        self.v_file.close();
    }

    pub fn assemble(self: *const Self) !void {
        try self.bin_file.writeAll("Writing this line to the file\n");
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

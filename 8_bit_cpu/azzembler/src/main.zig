const std = @import("std");
const azzembler = @import("azzembler");

pub fn main() !void {
    const count = std.os.argv.len;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    if (count == 2) {
        const assembler = try azzembler.Assembler.init(allocator, std.os.argv[1]);
        defer assembler.deinit();
        assembler.assemble();
    } else {
        std.debug.print("Usage: azzembler program.s\n", .{});
    }
}

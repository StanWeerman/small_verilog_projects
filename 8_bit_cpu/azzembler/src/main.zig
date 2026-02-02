const std = @import("std");
const azzembler = @import("azzembler");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const assembler = try azzembler.Assembler.init(allocator, std.os.argv);
    defer assembler.deinit();
    try assembler.assemble();
}

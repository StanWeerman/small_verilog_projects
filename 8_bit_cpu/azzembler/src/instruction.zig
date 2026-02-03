const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Instruction = union(enum) {
    const Self = @This();

    const Reg = u8;
    const Imm = u8;

    mov: struct { u8, Imm, Reg },
    add: struct { u8, u8, u8 },
    sub: struct { u8, u8, u8 },
    @"and": struct { u8, u8, u8 },
    @"or": struct { u8, u8, u8 },
    st: struct { u8, u8, u8 },
    ld: struct { u8, u8, u8 },
    jmp: struct { u8, u8, Reg },
    beq: struct { u8, u8, u8 },
    bne: struct { u8, u8, u8 },
    // uknown,

    pub const impl_map = std.StaticStringMap(Instruction).initComptime(get_instr());

    pub fn get_instr() []const struct { []const u8, Instruction } {
        const type_info = @typeInfo(Instruction);
        const enum_type = type_info.@"union".tag_type.?;

        const tags = std.meta.tags(enum_type);
        var res: [tags.len]struct { []const u8, Instruction } = undefined;
        for (tags, 0..) |tag, i| {
            // if (tag == .unknown) continue;
            const name = @tagName(tag);
            res[i] = .{ name, @unionInit(Instruction, name, .{ 1, 1, 1 }) };
        }
        return &res;
    }

    pub fn get(self: Instruction, id: u32, allocator: Allocator) []const u8 {
        switch (self) {
            inline else => |s| s.get(id, allocator),
        }
    }

    pub fn put(self: Instruction, data: anytype) void {
        switch (self) {
            inline else => |s| s.put(data),
        }
    }

    fn parse_instruction(instruction: []const u8) !Instruction {
        var path_iter = std.mem.tokenizeAny(u8, instruction, " ");
        if (path_iter.next()) |component_str| {
            const component = Instruction.impl_map.get(component_str);
            return component orelse .unknown;
        }
        return Instruction.InstructionError.BadInstructionLine;
    }
};

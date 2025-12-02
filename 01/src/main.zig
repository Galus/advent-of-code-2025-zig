const std = @import("std");
const _01 = @import("_01");

const Allocator = std.mem.Allocator;

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    try _01.bufferedPrint();

    var dial: i32 = 50;
    std.debug.print("dial: {d}.\n", .{dial});

    //const allocator = std.heap.page_allocator;
    const file_name = "input";

    const file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();

    const max_bytes = 10 * 1024 * 1024;
    var buffer: [max_bytes]u8 = undefined;
    var file_reader: std.fs.File.Reader = file.reader(&buffer);
    // const ioreader: *std.Io.Reader = &file_reader.interface;
    var password: usize = 0;
    while (file_reader.interface.takeDelimiterExclusive('\n')) |string| {
        std.debug.print("{s}\n", .{string});
        const direction = string[0];
        const rotation = try std.fmt.parseInt(i32, string[1..], 10);
        std.debug.print("{c}\n", .{direction});
        if (direction == 'R') {
            std.debug.print("Dialing right {d}\n", .{rotation});
            dial = @mod((dial + rotation + 1000), 100);
        } else {
            std.debug.print("Dialing left {d}\n", .{rotation});
            dial = @mod((dial - rotation + 1000), 100);
        }
        std.debug.print("Dial: {d}\n", .{dial});
        if (dial == 0) {
            password = password + 1;
        }
    } else |err| {
        std.debug.print("An error occured: {any}", .{err});
    }

    std.debug.print("Password: {d}\n", .{password});
}

test "simple test" {
    const gpa = std.testing.allocator;
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(gpa); // Try commenting this out and see if zig detects the memory leak!
    try list.append(gpa, 42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "fuzz example" {
    const Context = struct {
        fn testOne(context: @This(), input: []const u8) anyerror!void {
            _ = context;
            // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
            try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
        }
    };
    try std.testing.fuzz(Context{}, Context.testOne, .{});
}

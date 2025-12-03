const std = @import("std");
const _01 = @import("_01");
const Allocator = std.mem.Allocator;

pub fn wrapping_add(a: i32, b: i32, wrap: i32, wraps: *i32) i32 {
    const divs = @divFloor(a + b, wrap);
    wraps.* += divs;
    return @mod(a + b, wrap);
}

pub fn wrapping_sub(a: i32, b: i32, wrap: i32, wraps: *i32) i32 {
    var rhs: i32 = b;
    if (rhs >= wrap) {
        wraps.* += @divFloor(rhs, wrap);
        rhs = @mod(rhs, wrap);
    }
    if (a == rhs and a == 0) {
        return 0;
    }
    if (a == rhs) {
        wraps.* += 1;
        return 0;
    }

    if (rhs > a) {
        if (a != 0) {
            wraps.* += 1;
        }
        return a + wrap - rhs;
    }
    return a - rhs;
}

pub fn part1(lines: std.ArrayList([]u8)) !void {
    var dial: i32 = 50;
    // var zeroes = 0;
    const lines_slice = lines.items;
    const lines_slice_len = lines_slice.len;

    var answer: i32 = 0;
    for (0..lines_slice_len) |i| {
        const line = lines_slice[i];
        const op: u8 = line[0];
        const val: i32 = try std.fmt.parseInt(i32, line[1..], 10);
        var wraps: i32 = 0;
        switch (op) {
            'L' => dial = wrapping_sub(dial, val, 100, &wraps),
            'R' => dial = wrapping_add(dial, val, 100, &wraps),
            else => std.debug.print("Unknown operation {c}\n", .{op}),
        }
        if (dial == 0) {
            answer += 1;
        }
        //std.debug.print("{d}:\t{s}\t dial:{d}\t turning {c} by {d}\n", .{ i, line, dial, op, val });
    }
    std.debug.print("part 1: {d}\n", .{answer});
}

pub fn part2(lines: std.ArrayList([]u8)) !void {
    var dial: i32 = 50;
    const lines_slice = lines.items;
    const lines_slice_len = lines_slice.len;

    var answer2: i32 = 0;
    for (0..lines_slice_len) |i| {
        const line = lines_slice[i];
        const op: u8 = line[0];
        const val: i32 = try std.fmt.parseInt(i32, line[1..], 10);
        switch (op) {
            'L' => dial = wrapping_sub(dial, val, 100, &answer2),
            'R' => dial = wrapping_add(dial, val, 100, &answer2),
            else => std.debug.print("Unknown operation {c}\n", .{op}),
        }
        //std.debug.print("{d}:\t{s}\t dial:{d}\t turning {c} by {d}\n", .{ i, line, dial, op, val });
    }
    std.debug.print("part 2: {d}\n", .{answer2});
}

pub fn readFileIntoArrayList(allocator: std.mem.Allocator, file_path: []const u8) !std.ArrayList([]u8) {
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const max_bytes = 10 * 1024 * 1024;
    var buffer: [max_bytes]u8 = undefined;
    var file_reader: std.fs.File.Reader = file.reader(&buffer);

    var list = try std.ArrayList([]u8).initCapacity(allocator, max_bytes);
    errdefer list.deinit(allocator);

    while (file_reader.interface.takeDelimiterExclusive('\n')) |string| {
        try list.append(allocator, string);
    } else |err| {
        switch (err) {
            error.EndOfStream => {},
            else => std.debug.print("An error occured: {any}\n", .{err}),
        }
    }
    return list;
}

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    try _01.bufferedPrint();

    const allocator = std.heap.page_allocator;
    const lines: std.ArrayList([]u8) = try readFileIntoArrayList(allocator, "input");
    std.debug.print("\n", .{});
    try part1(lines);
    try part2(lines);
}

test "wrapping add tests" {
    var a: i32 = 55;
    var b: i32 = 55;
    var expected: i32 = 10;
    var wraps: i32 = 0;
    var ret = wrapping_add(a, b, 100, &wraps);
    // std.debug.print("returned: {d} with {d} wraps\n", .{ ret, wraps });
    try std.testing.expectEqual(expected, ret);
    try std.testing.expectEqual(1, wraps);

    a = 55;
    b = 505;
    expected = 60;
    wraps = 0;
    ret = wrapping_add(a, b, 100, &wraps);
    // std.debug.print("returned: {d} with {d} wraps\n", .{ ret, wraps });
    try std.testing.expectEqual(expected, ret);
    try std.testing.expectEqual(5, wraps);

    a = 55;
    b = 505;
    expected = 60;
    wraps = 0;
    ret = wrapping_add(a, b, 100, &wraps);
    // std.debug.print("returned: {d} with {d} wraps\n", .{ ret, wraps });
    try std.testing.expectEqual(expected, ret);
    try std.testing.expectEqual(5, wraps);

    a = 99;
    b = 5;
    expected = 4;
    wraps = 0;
    ret = wrapping_add(a, b, 100, &wraps);
    // std.debug.print("returned: {d} with {d} wraps\n", .{ ret, wraps });
    try std.testing.expectEqual(expected, ret);
    try std.testing.expectEqual(1, wraps);

    a = 0;
    b = 5;
    expected = 5;
    wraps = 0;
    ret = wrapping_add(a, b, 100, &wraps);
    // std.debug.print("returned: {d} with {d} wraps\n", .{ ret, wraps });
    try std.testing.expectEqual(expected, ret);
    try std.testing.expectEqual(0, wraps);
}

test "aoc part1" {
    std.debug.print("part 1 test\n", .{});
    const input =
        \\L68
        \\L30
        \\R48
        \\L5
        \\R60
        \\L55
        \\L1
        \\L99
        \\R14
        \\L82
    ;
    var dial: i32 = 50;
    var wraps: i32 = 0;
    var count: i32 = 0;
    var iterator = std.mem.splitSequence(u8, input, "\n");
    while (iterator.next()) |line| {
        const op: u8 = line[0];
        const val: i32 = try std.fmt.parseInt(i32, line[1..], 10);
        std.debug.print("op: {c}\t val: {d}\n", .{ op, val });
        if (op == 'R') {
            dial = wrapping_add(dial, val, 100, &wraps);
        }
        if (op == 'L') {
            dial = wrapping_sub(dial, val, 100, &wraps);
        }
        if (dial == 0) {
            count += 1;
        }
    }
    try std.testing.expectEqual(dial, 32);
    try std.testing.expectEqual(wraps, 6);
    try std.testing.expectEqual(count, 3);
}

test "aoc part2" {
    std.debug.print("aoc part2\n", .{});
    const input =
        \\L68
        \\L30
        \\R48
        \\L5
        \\R60
        \\L55
        \\L1
        \\L99
        \\R14
        \\L82
        \\L32
        \\R2
        \\L3
    ;
    var dial: i32 = 50;
    var wraps: i32 = 0;
    var count: i32 = 0;
    var iterator = std.mem.splitSequence(u8, input, "\n");
    while (iterator.next()) |line| {
        const op: u8 = line[0];
        const val: i32 = try std.fmt.parseInt(i32, line[1..], 10);
        std.debug.print("dial: {d} \t op: {c}\t val: {d} \t wraps: {d}\t count: {d}\n", .{ dial, op, val, wraps, count });
        if (op == 'R') {
            dial = wrapping_add(dial, val, 100, &wraps);
        }
        if (op == 'L') {
            dial = wrapping_sub(dial, val, 100, &wraps);
        }
        if (dial == 0) {
            count += 1;
            std.debug.print("Stopped at 0\n", .{});
        }
    }
    try std.testing.expectEqual(count, 4);
    try std.testing.expectEqual(8, wraps);
}

test "aoc part2 edgecase 0 left" {
    std.debug.print("part 2 edgecase 0 left test\n", .{});
    const input =
        \\L50
        \\L5
        \\R1
        \\R1
        \\R1
        \\R1
        \\R1
        \\R1
    ;
    var dial: i32 = 50;
    var wraps: i32 = 0;
    var count: i32 = 0;
    var iterator = std.mem.splitSequence(u8, input, "\n");
    while (iterator.next()) |line| {
        const op: u8 = line[0];
        const val: i32 = try std.fmt.parseInt(i32, line[1..], 10);
        std.debug.print("dial: {d} \t op: {c}\t val: {d} \t wraps: {d}\t count: {d}\n", .{ dial, op, val, wraps, count });
        if (op == 'R') {
            dial = wrapping_add(dial, val, 100, &wraps);
        }
        if (op == 'L') {
            dial = wrapping_sub(dial, val, 100, &wraps);
        }
        if (dial == 0) {
            count += 1;
            std.debug.print("Stopped at 0\n", .{});
        }
    }
    try std.testing.expectEqual(count, 2);
    try std.testing.expectEqual(wraps, 2);
}

test "wrapping sub tests" {
    std.debug.print("wrapping sub tests\ninner test1\n", .{});
    var a: i32 = 55;
    var b: i32 = 55;
    var wraps: i32 = 0;
    var ret = wrapping_sub(a, b, 100, &wraps);
    try std.testing.expectEqual(0, ret);
    try std.testing.expectEqual(1, wraps);

    std.debug.print("inner tests2\n", .{});
    a = 55;
    b = 505;
    wraps = 0;
    ret = wrapping_sub(a, b, 100, &wraps);
    try std.testing.expectEqual(50, ret);
    try std.testing.expectEqual(5, wraps);

    std.debug.print("inner tests3\n", .{});
    a = 10;
    b = 98;
    wraps = 0;
    ret = wrapping_sub(a, b, 100, &wraps);
    try std.testing.expectEqual(12, ret);
    try std.testing.expectEqual(1, wraps);

    std.debug.print("inner tests4\n", .{});
    a = 10;
    b = 598;
    wraps = 0;
    ret = wrapping_sub(a, b, 100, &wraps);
    try std.testing.expectEqual(12, ret);
    try std.testing.expectEqual(6, wraps);
}

test "wrapping sub tests again" {
    std.debug.print("wrapping sub tests again\n", .{});
    const a: i32 = 1;
    const b: i32 = 1005;
    var wraps: i32 = 0;
    const ret = wrapping_sub(a, b, 100, &wraps);
    try std.testing.expectEqual(96, ret);
    try std.testing.expectEqual(11, wraps);
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

const std = @import("std");

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    var file = try std.fs.cwd().openFile("resources/testdata.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    var sum: u32 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var split = std.mem.split(u8, std.mem.trim(u8, line, "\n\r"), " ");
        var previousNumber = try std.fmt.parseInt(i32, split.next().?, 10);
        var isNegative: ?bool = null;
        var isSafe = true;
        while (split.next()) |n| {
            const number = try std.fmt.parseInt(i32, n, 10);
            const diff = previousNumber - number;
            if (diff == 0) {
                isSafe = false;
                break;
            }
            if (isNegative == null) isNegative = diff < 0;
            if (isNegative.? and diff > 0) {
                isSafe = false;
                break;
            }
            if (!isNegative.? and diff < 0) {
                isSafe = false;
                break;
            }
            if (@abs(diff) > 3) {
                isSafe = false;
                break;
            }

            previousNumber = number;
        }

        if (isSafe) sum += 1;
    }

    std.debug.print("Amount of safe reports: {d}\n", .{sum});
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

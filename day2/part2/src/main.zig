const std = @import("std");

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    var file = try std.fs.cwd().openFile("resources/testdata.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var sum: u32 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var split = std.mem.split(u8, std.mem.trim(u8, line, "\n\r"), " ");

        var list = std.ArrayList(i32).init(allocator);
        defer list.deinit();

        while (split.next()) |n| {
            const number = try std.fmt.parseInt(i32, n, 10);
            try list.append(number);
        }

        if (isSafeReport(list)) sum += 1;
    }

    std.debug.print("Amount of safe reports: {d}\n", .{sum});
}

fn isSafeReport(report: std.ArrayList(i32)) bool {
    return isSafeReport_internal(report, true);
}

fn isSafeReport_internal(report: std.ArrayList(i32), canSkip: bool) bool {
    var previousNumber: ?i32 = null;
    var isNegative: ?bool = null;

    for (report.items, 0..) |number, idx| {
        if (previousNumber == null) {
            previousNumber = number;
            continue;
        }

        const diff = previousNumber.? - number;
        if (isNegative == null) isNegative = diff < 0;
        if (diff == 0 or (isNegative.? and diff > 0) or (!isNegative.? and diff < 0) or @abs(diff) > 3) {
            if (canSkip) {
                var copy1 = report.clone() catch return false;
                defer copy1.deinit();
                _ = copy1.orderedRemove(idx);
                if (isSafeReport_internal(copy1, false)) return true;

                var copy2 = report.clone() catch return false;
                defer copy2.deinit();
                _ = copy2.orderedRemove(idx - 1);
                if (isSafeReport_internal(copy2, false)) return true;

                if (idx == 2) {
                    var copy3 = report.clone() catch return false;
                    defer copy3.deinit();
                    _ = copy3.orderedRemove(idx - 2);
                    if (isSafeReport_internal(copy3, false)) return true;
                }

                return false;
            }
            return false;
        }

        previousNumber = number;
    }

    return true;
}

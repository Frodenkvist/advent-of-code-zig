const std = @import("std");

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    var file = try std.fs.cwd().openFile("resources/testdata.txt", .{});
    // var file = try std.fs.cwd().openFile("resources/smalldata.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [4096]u8 = undefined;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var rules = std.AutoHashMap(u32, std.ArrayList(u32)).init(allocator);
    defer rules.deinit();

    var readingRules = true;
    var sum: u32 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const trimmedLine = std.mem.trimRight(u8, line, "\n\r");

        if (readingRules) {
            if (trimmedLine.len == 0) {
                readingRules = false;
                continue;
            }

            var split = std.mem.split(u8, trimmedLine, "|");

            const num1 = try std.fmt.parseInt(u32, split.next().?, 10);
            const num2 = try std.fmt.parseInt(u32, split.next().?, 10);

            const value = try rules.getOrPut(num1);
            if (value.found_existing) {
                try value.value_ptr.*.append(num2);
            } else {
                var list = std.ArrayList(u32).init(allocator);
                try list.append(num2);
                value.value_ptr.* = list;
            }

            continue;
        }

        var split = std.mem.split(u8, trimmedLine, ",");
        var numbers = std.ArrayList(u32).init(allocator);
        defer numbers.deinit();

        while (split.next()) |number| {
            const num = try std.fmt.parseInt(u32, number, 10);
            try numbers.append(num);
        }

        outer: for (numbers.items, 0..) |number, idx| {
            const rule = rules.get(number);
            if (rule == null) {
                continue;
            }

            for (0..idx) |i| {
                const previousNumber = numbers.items[i];

                if (contains(u32, rule.?.items, previousNumber)) {
                    sort(numbers.items, rules);
                    sum += numbers.items[numbers.items.len / 2];
                    break :outer;
                }
            }
        }
    }

    std.debug.print("Sum of middle numbers {d}\n", .{sum});
}

fn contains(comptime T: type, haystack: []const T, needle: T) bool {
    for (haystack) |item| {
        if (item == needle) return true;
    }
    return false;
}

fn sort(array: []u32, rules: std.AutoHashMap(u32, std.ArrayList(u32))) void {
    var length = array.len;
    while (length > 1) {
        var newLength: usize = 0;
        for (array[0 .. length - 1], 0..) |value, i| {
            const rule = rules.get(array[i + 1]);
            if (rule != null and contains(u32, rule.?.items, value)) {
                std.mem.swap(u32, &array[i], &array[i + 1]);
                newLength = i + 1;
            }
        }
        length = newLength;
    }
}

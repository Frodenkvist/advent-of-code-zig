const std = @import("std");

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var file = try std.fs.cwd().openFile("resources/testdata.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var list1 = std.ArrayList(i32).init(allocator);
    defer list1.deinit();
    var map = std.AutoHashMap(i32, i32).init(allocator);
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var split = std.mem.split(u8, line, "   ");
        const num1 = try std.fmt.parseInt(i32, split.next().?, 10);
        const num2 = try std.fmt.parseInt(i32, std.mem.trim(u8, split.next().?, "\n\r"), 10);
        try list1.append(num1);
        const value = try map.getOrPut(num2);
        if (!value.found_existing) {
            value.value_ptr.* = 1;
        } else {
            value.value_ptr.* = value.value_ptr.* + 1;
        }
    }

    var sum: i32 = 0;

    for (list1.items) |item1| {
        const value = map.get(item1);
        if (value) |v| {
            sum += item1 * v;
        }
    }

    try stdout.print("Sum: {d}\n", .{sum});

    try bw.flush(); // don't forget to flush!
}

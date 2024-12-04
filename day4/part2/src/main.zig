const std = @import("std");

const GRID_X = 140;
const GRID_Y = 140;

pub fn main() !void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    // var file = try std.fs.cwd().openFile("resources/smalldata.txt", .{});
    var file = try std.fs.cwd().openFile("resources/testdata.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [4096]u8 = undefined;

    var grid: [GRID_X][GRID_Y]u8 = undefined;

    var idx: u32 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const trimmedLine = std.mem.trimRight(u8, line, "\n\r");

        for (trimmedLine, 0..) |c, x| {
            grid[x][idx] = c;
        }

        idx += 1;
    }

    var sum: u32 = 0;

    for (grid, 0..) |column, x| {
        for (column, 0..) |c, y| {
            if (c == 'A')
                sum += countXMasAtPosition(grid, @intCast(x), @intCast(y));
        }
    }

    std.debug.print("Amount of X-MAS found: {d}\n", .{sum});
}

fn countXMasAtPosition(grid: [GRID_X][GRID_Y]u8, x: i32, y: i32) u32 {
    if (x + 1 >= GRID_X or y + 1 >= GRID_Y)
        return 0;
    if (x - 1 < 0 or y - 1 < 0)
        return 0;

    if ((grid[@intCast(x + 1)][@intCast(y + 1)] != 'M' or grid[@intCast(x - 1)][@intCast(y - 1)] != 'S') and
        (grid[@intCast(x + 1)][@intCast(y + 1)] != 'S' or grid[@intCast(x - 1)][@intCast(y - 1)] != 'M'))
        return 0;

    if ((grid[@intCast(x + 1)][@intCast(y - 1)] != 'M' or grid[@intCast(x - 1)][@intCast(y + 1)] != 'S') and
        (grid[@intCast(x + 1)][@intCast(y - 1)] != 'S' or grid[@intCast(x - 1)][@intCast(y + 1)] != 'M'))
        return 0;

    return 1;
}

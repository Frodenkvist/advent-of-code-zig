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
            if (c == 'X')
                sum += countXmasAtPosition(grid, @intCast(x), @intCast(y));
        }
    }

    std.debug.print("Amount of XMAS found: {d}\n", .{sum});
}

fn countXmasAtPosition(grid: [GRID_X][GRID_Y]u8, x: i32, y: i32) u32 {
    var sum: u32 = 0;

    if (checkInDirection(grid, x, y, .{ 1, 0 }))
        sum += 1;
    if (checkInDirection(grid, x, y, .{ 0, 1 }))
        sum += 1;
    if (checkInDirection(grid, x, y, .{ -1, 0 }))
        sum += 1;
    if (checkInDirection(grid, x, y, .{ 0, -1 }))
        sum += 1;
    if (checkInDirection(grid, x, y, .{ 1, 1 }))
        sum += 1;
    if (checkInDirection(grid, x, y, .{ -1, 1 }))
        sum += 1;
    if (checkInDirection(grid, x, y, .{ 1, -1 }))
        sum += 1;
    if (checkInDirection(grid, x, y, .{ -1, -1 }))
        sum += 1;

    return sum;
}

fn checkInDirection(grid: [GRID_X][GRID_Y]u8, x: i32, y: i32, direction: [2]i32) bool {
    if (x + (direction[0] * 3) >= GRID_X or y + (direction[1] * 3) >= GRID_Y)
        return false;
    if (x + (direction[0] * 3) < 0 or y + (direction[1] * 3) < 0)
        return false;

    const xmasString = "XMAS";

    for (1..4) |idx| {
        const newX = @as(usize, @intCast(x + direction[0] * @as(i32, @intCast(idx))));
        const newY = @as(usize, @intCast(y + direction[1] * @as(i32, @intCast(idx))));

        if (grid[newX][newY] != xmasString[idx])
            return false;
    }

    return true;
}

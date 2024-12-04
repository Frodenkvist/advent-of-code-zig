const std = @import("std");

const MulParser = struct {
    sum: u32 = 0,
    startIdx: u32 = 0,
    firstNumber: [3]u8 = undefined,
    firstNumberIdx: u32 = 0,
    secondNumber: [3]u8 = undefined,
    secondNumberIdx: u32 = 0,
    commaFound: bool = false,

    const mulStart = [_]u8{ 'm', 'u', 'l', '(' };
    const digits = [_]u8{ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' };

    pub fn parseNext(self: *MulParser, char: u8) !void {
        if (self.startIdx < 4) {
            if (char != mulStart[self.startIdx]) {
                self.reset();
            } else {
                self.startIdx += 1;
            }
            return;
        }

        if (!self.commaFound and self.firstNumberIdx <= 3) {
            const isDigit = contains(u8, &digits, char);
            if ((!isDigit and self.firstNumberIdx == 0) or (isDigit and self.firstNumberIdx == 3)) {
                self.reset();
                return;
            }

            if (isDigit) {
                // std.debug.print("First number: {c}\n", .{char});
                self.firstNumber[self.firstNumberIdx] = char;
                self.firstNumberIdx += 1;
            } else if (char == ',') {
                self.commaFound = true;
            } else {
                self.reset();
                return;
            }
        } else if (self.commaFound and self.secondNumberIdx < 3) {
            const isDigit = contains(u8, &digits, char);
            if (!isDigit and self.secondNumberIdx == 0) {
                self.reset();
                return;
            }

            if (isDigit) {
                // std.debug.print("Second number: {c}\n", .{char});
                self.secondNumber[self.secondNumberIdx] = char;
                self.secondNumberIdx += 1;
            } else if (self.firstNumberIdx > 0 and self.secondNumberIdx > 0 and char == ')') {
                // std.debug.print("The success: mul({s},{s})\n", .{ self.firstNumber[0..self.firstNumberIdx], self.secondNumber[0..self.secondNumberIdx] });
                self.sum += try std.fmt.parseInt(u32, self.firstNumber[0..self.firstNumberIdx], 10) *
                    try std.fmt.parseInt(u32, self.secondNumber[0..self.secondNumberIdx], 10);

                self.reset();
                return;
            } else {
                self.reset();
                return;
            }
        } else if (self.firstNumberIdx > 0 and self.secondNumberIdx > 0 and char == ')') {
            // std.debug.print("The success: mul({s},{s})\n", .{ self.firstNumber[0..self.firstNumberIdx], self.secondNumber[0..self.secondNumberIdx] });
            self.sum += try std.fmt.parseInt(u32, self.firstNumber[0..self.firstNumberIdx], 10) *
                try std.fmt.parseInt(u32, self.secondNumber[0..self.secondNumberIdx], 10);

            self.reset();
            return;
        } else {
            self.reset();
            return;
        }
    }

    fn reset(self: *MulParser) void {
        self.startIdx = 0;
        self.firstNumber = undefined;
        self.firstNumberIdx = 0;
        self.secondNumber = undefined;
        self.secondNumberIdx = 0;
        self.commaFound = false;
    }
};

pub fn main() !void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    var file = try std.fs.cwd().openFile("resources/testdata.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [4096]u8 = undefined;

    var parser = MulParser{};

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const trimmedLine = std.mem.trimRight(u8, line, "\n\r");

        for (trimmedLine) |c| {
            try parser.parseNext(c);
        }
    }

    std.debug.print("Sum of products: {d}\n", .{parser.sum});
}

fn contains(comptime T: type, haystack: []const T, needle: T) bool {
    for (haystack) |item| {
        if (item == needle) return true;
    }
    return false;
}

const std = @import("std");
const fs = std.fs;
const print = std.debug.print;

const Range = struct {
    start: i64,
    end: i64,
};

fn isRepeatedTwice(num: i64, allocator: std.mem.Allocator) !bool {
    // Convert number to string
    const num_str = try std.fmt.allocPrint(allocator, "{d}", .{num});
    defer allocator.free(num_str);

    // Length must be even in order to have repeated halves
    if (num_str.len % 2 != 0) return false;

    const half_len = num_str.len / 2;
    const first_half = num_str[0..half_len];
    const second_half = num_str[half_len..];

    // Check if both halves are identical
    return std.mem.eql(u8, first_half, second_half);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Open input file
    const file = try fs.cwd().openFile("../input", .{});
    defer file.close();

    // Read the entire file contents
    const contents = try file.readToEndAlloc(allocator, 1024 * 1024); // 1MB max
    defer allocator.free(contents);

    // Trim and clean up line
    const line = std.mem.trimRight(u8, contents, "\n\r");

    // Use ArrayList for dynamic array
    var ranges = try std.ArrayList(Range).initCapacity(allocator, 1024 * 1024);
    defer ranges.deinit(allocator);

    // Split by command and parse each range
    var iter = std.mem.splitScalar(u8, line, ',');
    while (iter.next()) |range| {
        const trimmed = std.mem.trim(u8, range, " \t\n\r");
        if (trimmed.len > 0) {
            // Split by hyphen to get start and end of range
            var range_iter = std.mem.splitScalar(u8, trimmed, '-');
            const start_str = range_iter.next() orelse continue;
            const end_str = range_iter.next() orelse continue;

            const start = try std.fmt.parseInt(i64, start_str, 10);
            const end = try std.fmt.parseInt(i64, end_str, 10);

            try ranges.append(allocator, Range{ .start = start, .end = end });
        }
    }

    var sum: i64 = 0;
    for (ranges.items) |range| {
        // print("Checking range {d}-{d}:\n", .{ range.start, range.end });

        var found = false;
        var num = range.start;
        while (num <= range.end) : (num += 1) {
            if (try isRepeatedTwice(num, allocator)) {
                // print("  Found: {d}\n", .{num});
                sum += num;
                found = true;
            }
        }
    }

    print("Sum: {d}", .{sum});
}

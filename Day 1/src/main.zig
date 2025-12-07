const std = @import("std");
const fs = std.fs;
const print = std.debug.print;

pub fn main() !void {
    // Open the file
    const file = try fs.cwd().openFile("../input", .{});
    defer file.close();

    // Read the entire file into buffer
    const file_size = (try file.stat()).size;
    const allocator = std.heap.page_allocator;
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);
    _ = try file.readAll(buffer);

    // Create a fixed buffer stream
    var stream = std.io.fixedBufferStream(buffer);
    const reader = stream.reader();

    // Buffer to store each line
    var line_buffer: [1024]u8 = undefined;

    // Read and process lines
    var line_num: usize = 1;
    var position: i32 = 50; // Starting position
    var zero_count: usize = 0; // Count number of times we land on zero
    while (true) {
        const maybe_line = reader.readUntilDelimiterOrEof(&line_buffer, '\n') catch |err| switch (err) {
            error.StreamTooLong => {
                // Line too long for our buffer
                try reader.skipUntilDelimiterOrEof('\n');
                continue;
            },
            else => return err,
        };

        if (maybe_line) |line| {
            // Process line
            // Parse the direction and distance
            if (line.len > 0) {
                const direction = line[0];
                const number_str = std.mem.trim(u8, line[1..], &std.ascii.whitespace);

                // Convert string to int
                const number = try std.fmt.parseInt(i32, number_str, 10);

                // Process instruction
                switch (direction) {
                    'R' => {
                        position = @mod(position + number, 100);
                    },
                    'L' => {
                        position = @mod(position - number, 100);
                    },
                    else => {},
                }

                if (position == 0) {
                    zero_count += 1;
                    // print("Line {d}: Landed on 0!\n", .{line_num});
                }
            }

            // Increment line number
            line_num += 1;
        } else {
            break;
        }
    }

    print("\nTotal lines read: {d}\n", .{line_num - 1});
    print("Times landed on 0: {d}", .{zero_count});
}

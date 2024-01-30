const std = @import("std");
const cli = @import("lib/zig-cli/src/main.zig");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

var config = struct {
    host: []const u8 = "localhost",
    port: u16 = undefined,
}{};

var host = cli.Option{
    .long_name = "host",
    .help = "host to listen on",
    .value_ref = cli.mkRef(&config.host),
};
var port = cli.Option{
    .long_name = "port",
    .help = "port to bind to",
    .required = true,
    .value_ref = cli.mkRef(&config.port),
};
var app = &cli.App{
    .command = cli.Command{
        .name = "short",
        .options = &.{ &host, &port },
        .target = cli.CommandTarget{
            .action = cli.CommandAction{ .exec = run_server },
        },
    },
};

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!

    return cli.run(app, allocator);
}

pub fn run_server() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("server is listening on {s}:{}\n", .{ config.host, config.port });
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

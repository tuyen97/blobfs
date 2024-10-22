//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");
const server = @import("./tcp.zig");

pub fn main() !void {
    std.debug.print("Hello, Wolrd!", .{});
    server.Server.init(8000);
}

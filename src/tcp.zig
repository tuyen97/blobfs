const std = @import("std");
const net = std.net;
const posix = std.posix;

pub const Server = struct {
    stream_server: net.Server,
    gpa: std.heap.HeapAllocator,

    pub fn init(port: u16) !Server {
        const address = net.Address.initIp4([4]u8{ 127, 0, 0, 1 }, port);

        // more information about `reuse_address`: http://unixguide.net/network/socketfaq/4.5.shtml
        const server = try address.listen(.{ .reuse_address = true });

        // start listening at 127.0.0.1:8080
        std.log.info("Server listening on port 8080", .{});

        return Server{
            .stream_server = server,
            .gpa = std.heap.GeneralPurposeAllocator(.{}){},
        };
    }

    pub fn deinit(self: *Server) void {
        self.stream_server.deinit();
    }

    pub fn accept(self: *Server) !void {
        var client = try self.stream_server.accept();
        defer client.stream.close();

        const client_reader = client.stream.reader();
        const client_writer = client.stream.writer();

        while (true) {
            const msg = try client_reader.readUntilDelimiterOrEofAlloc(self.gpa, '\n', 65536) orelse break;
            std.log.info("Recieved message: \"{}\"", .{std.zig.fmtEscapes(msg)});

            try client_writer.writeAll(msg);
        }
    }
};

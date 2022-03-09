const std = @import("std");
const N = 10;

const stdin = std.io.getStdIn();

pub fn main() !void {
    var line_buff: [100]u8 = undefined;
    const node_line = try stdin.reader().readUntilDelimiter(&line_buff, '\n');
    const nodes = try std.fmt.parseInt(usize, node_line, 10);
    std.debug.print("Nodes {d}\n", .{nodes});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var qf = try allocator.alloc(usize, nodes);
    defer allocator.free(qf);

    for (qf) |_, i| {
        qf[i] = i;
    }

    while (try stdin.reader().readUntilDelimiterOrEof(&line_buff, '\n')) |line| {
        //std.debug.print("line {s}\n", .{line});
        var it = std.mem.tokenize(u8, line, " \n");
        const a = try std.fmt.parseInt(usize, it.next().?, 10);
        const b = try std.fmt.parseInt(usize, it.next().?, 10);
        join(&qf, a, b);
    }

    std.debug.print("Connected {}\n", .{connected(&qf, 0, 1)});
}

fn connected(qf: *[]usize, p: usize, q: usize) bool {
    return qf.*[p] == qf.*[q];
}

fn join(qf: *[]usize, p: usize, q: usize) void {
    const pid = qf.*[p];
    const qid = qf.*[q];

    for (qf.*) |*val| {
        if (val.* == pid) val.* = qid;
    }
}

test "connect-and-join" {
    var qf = [_]usize{0} ** N;
    for (qf) |_, i| {
        qf[i] = i;
    }
    try std.testing.expect(!connected(&qf, 0, 1));
    join(&qf, 0, 1);
    try std.testing.expect(connected(&qf, 0, 1));
}

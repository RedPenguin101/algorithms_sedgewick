const std = @import("std");
const stdIn = std.io.getStdIn();

pub fn main() !void {
    var buffer = std.io.bufferedReader(stdIn.reader());
    const reader = buffer.reader();

    var line_buff: [100]u8 = undefined;
    const node_line = try reader.readUntilDelimiter(&line_buff, '\n');
    var nodes = try std.fmt.parseInt(usize, node_line, 10);
    std.debug.print("Nodes {d}:\n", .{nodes});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var qu = try new_qu(&nodes, allocator);
    defer allocator.free(qu.id);
    defer allocator.free(qu.sizes);

    while (try reader.readUntilDelimiterOrEof(&line_buff, '\n')) |line| {
        var it = std.mem.tokenize(u8, line, " \n");
        const a = try std.fmt.parseInt(usize, it.next().?, 10);
        const b = try std.fmt.parseInt(usize, it.next().?, 10);
        join(qu, a, b);
    }

    std.debug.print("Connected Components: {}\n", .{qu.count.*});
}

const QU = struct { id: []usize, sizes: []usize, count: *usize };

fn new_qu(nodes: *usize, allocator: std.mem.Allocator) !QU {
    var qf = try allocator.alloc(usize, nodes.*);
    var sizes = try allocator.alloc(usize, nodes.*);
    var qu = QU{
        .id = qf,
        .sizes = sizes,
        .count = nodes,
    };
    for (qu.id) |_, i| {
        qu.id[i] = i;
        qu.sizes[i] = 1;
    }

    return qu;
}

fn join(qu: QU, p: usize, q: usize) void {
    const i = root(qu, p);
    const j = root(qu, q);
    if (i == j) return;
    const i_size = qu.sizes[i];
    const j_size = qu.sizes[j];

    if (i_size < j_size) {
        qu.id[i] = j;
        qu.sizes[j] = i_size + j_size;
    } else {
        qu.id[j] = i;
        qu.sizes[i] = i_size + j_size;
    }
    qu.count.* -= 1;
}

fn root(qu: QU, p: usize) usize {
    var i: usize = p;
    while (qu.id[i] != i) {
        qu.id[i] = qu.id[qu.id[i]];
        i = qu.id[i];
    }
    return i;
}

fn connected(qu: QU, p: usize, q: usize) bool {
    return root(qu, p) == root(qu, q);
}

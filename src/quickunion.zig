const std = @import("std");
const N = 10;

const stdin = std.io.getStdIn();

pub fn main() !void {
    var file = try std.fs.cwd().openFile("./resources/largeUF.txt", .{});
    defer file.close();

    var line_buff: [100]u8 = undefined;
    const node_line = try file.reader().readUntilDelimiter(&line_buff, '\n');
    const nodes = try std.fmt.parseInt(usize, node_line, 10);
    std.debug.print("Nodes {d}\n", .{nodes});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var qf = try allocator.alloc(usize, nodes);
    var sizes = try allocator.alloc(usize, nodes);
    defer allocator.free(qf);
    defer allocator.free(sizes);

    for (qf) |_, i| {
        qf[i] = i;
        sizes[i] = 1;
    }

    while (try file.reader().readUntilDelimiterOrEof(&line_buff, '\n')) |line| {
        var it = std.mem.tokenize(u8, line, " \n");
        const a = try std.fmt.parseInt(usize, it.next().?, 10);
        const b = try std.fmt.parseInt(usize, it.next().?, 10);
        join(&qf, &sizes, a, b);
    }

    std.debug.print("Connected {}\n", .{connected(&qf, 0, 1)});
}

fn join(qf: *[]usize, sizes: *[]usize, p: usize, q: usize) void {
    const i = root(qf, p);
    const j = root(qf, q);
    if (i == j) return;
    const i_size = sizes.*[i];
    const j_size = sizes.*[j];

    if (i_size < j_size) {
        qf.*[i] = j;
        sizes.*[j] = i_size + j_size;
    } else {
        qf.*[j] = i;
        sizes.*[i] = i_size + j_size;
    }
}

fn root(qf: *[]usize, p: usize) usize {
    var i: usize = p;
    while (qf.*[i] != i) {
        qf.*[i] = qf.*[qf.*[i]];
        i = qf.*[i];
    }
    return i;
}

fn connected(qf: *[]usize, p: usize, q: usize) bool {
    return root(qf, p) == root(qf, q);
}

test "root" {
    var ta = std.testing.allocator;
    var qf = try ta.alloc(usize, 5);
    var sizes = try ta.alloc(usize, 5);
    defer ta.free(qf);
    defer ta.free(sizes);

    for (qf) |_, i| {
        qf[i] = i;
        sizes[i] = 1;
    }

    try std.testing.expectEqual(root(qf, 0), 0);
    join(&qf, &sizes, 1, 0);
    try std.testing.expectEqual(root(qf, 1), 0);
}

//test "connect-and-join" {
//    var qf = [_]usize{0} ** N;
//    for (qf) |_, i| {
//        qf[i] = i;
//    }
//    try std.testing.expect(!connected(&qf, 0, 1));
//    join(&qf, 0, 1);
//    try std.testing.expect(connected(&qf, 0, 1));
//}

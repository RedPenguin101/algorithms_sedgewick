# Lecture 1: Union Find

## Dynamic Connectivity
Given set of N objects

* `union(a,b)`
* `connected(a,b)`

Assumptions:

1. Reflexive
2. Symmetric
3. Transitive

Connected components: number of 'groups' of connected nodes.

* `find(p)`: identify component for node
* `count()` number of components

## Quick Find
* "Eager" algorithm.
* Data structure = array. index is node, value is component
* find: nodes are connected if they have the same value/component
* union: merging components. Change all entries with `id[p]` to `id[q]`

```zig
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
```

* Problem: union too expensive, have to loop through the whole array. Takes $N^2$ array accesses for N union commands on N objects.

## Quick Union
* "Lazy approach". Avoid doing work
* Same data structure, array
* Different interpretation: `id[i]` is parent of `i`.
* Root is the 'walk' up the tree, until `id[i]=i`
* connected is 'do they have the same root'?
* Union: set the parent of root of p to root of q
* Still too slow, trees get tall so root gets expensive (N accesses)

```zig
fn join(qf: *[]usize, p: usize, q: usize) void {
    const proot = root(qf.*, p);
    qf.*[proot] = root(qf.*, q);
}

fn root(qf: []const usize, p: usize) usize {
    var i: usize = p;
    while (qf[i] != i) i = qf[i];
    return i;
}

fn connected(qf: []const usize, p: usize, q: usize) bool {
    return root(qf, p) == root(qf, q);
}
```

## Improved Quick Union: Weighting
* modify QU to avoid tall trees.
* track the size of each tree (number of objects)
* when joining, link smaller tree to larger tree

```zig
fn join(qf: *[]usize, sizes: *[]usize, p: usize, q: usize) void {
    const i = root(qf.*, p);
    const j = root(qf.*, q);
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

fn root(qf: []const usize, p: usize) usize {
    var i: usize = p;
    while (qf[i] != i) i = qf[i];
    return i;
}

fn connected(qf: []const usize, p: usize, q: usize) bool {
    return root(qf, p) == root(qf, q);
}
```

* Much faster
* Find takes time proportional to p and q
* union takes constant time (given roots)
* depth of any node x is at most lg N

## Improved Quick Union 2: Path compression

const std = @import("std");

// Game-specific constants
const NUM_PLAYERS = 4;
const NUM_GAMES = 5;
const MIN_TARGET = 1;
const MAX_TARGET = 13;

const Player = struct {
    name: []const u8,
    points: i32 = 0,
    overtricks: i32 = 0,
};

const GamePoints = struct {
    target: []const u8,
    overtricks: []const u8,
};

const Game = struct {
    points: [NUM_PLAYERS]GamePoints,
};

/// Gets integer input from user with validation
fn getIntInput(
    writer: anytype,
    reader: anytype,
    prompt: []const u8,
    condition: *const fn (i32) bool,
    error_msg: []const u8,
) !i32 {
    var buf: [100]u8 = undefined;

    while (true) {
        try writer.print("{s}", .{prompt});

        if (try reader.readUntilDelimiterOrEof(&buf, '\n')) |user_input| {
            const trimmed = std.mem.trim(u8, user_input, " \t\r\n");
            if (std.fmt.parseInt(i32, trimmed, 10)) |value| {
                if (condition(value)) return value;
                try writer.print("{s}\n", .{error_msg});
            } else |_| {
                try writer.print("Please input a valid number\n", .{});
            }
        } else {
            return error.InvalidInput;
        }
    }
}

fn isValidTarget(value: i32) bool {
    return value >= MIN_TARGET and value <= MAX_TARGET;
}

fn isValidHands(value: i32) bool {
    return value >= MIN_TARGET and value <= MAX_TARGET;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Print header
    try stdout.print("{s}   Call Break Calculator   {s}\n\n", .{
        "**********",
        "**********",
    });

    // Initialize players
    var players: [NUM_PLAYERS]Player = undefined;
    var buf: [100]u8 = undefined;

    // Get player names
    for (0..NUM_PLAYERS) |i| {
        try stdout.print("Please tell the name of player {d} : ", .{i + 1});
        if (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |user_input| {
            const name = try allocator.dupe(u8, std.mem.trim(u8, user_input, " \t\r\n"));
            players[i] = .{ .name = name };
        }
    }

    // Print players
    try stdout.print("\nPlayers are:\n", .{});
    for (players) |player| {
        try stdout.print("\t{s}", .{player.name});
    }
    try stdout.print("\n\n", .{});

    // Store game history
    var games = std.ArrayList(Game).init(allocator);
    defer games.deinit();

    // Main game loop
    for (0..NUM_GAMES) |game_num| {
        try stdout.print("\nGame {d}\n", .{game_num + 1});

        var targets: [NUM_PLAYERS]i32 = undefined;
        // Get targets for each player
        for (0..NUM_PLAYERS) |i| {
            const player_index = (game_num + i) % NUM_PLAYERS;
            const prompt = try std.fmt.allocPrint(allocator, "Please input target for {s} = ", .{players[player_index].name});
            defer allocator.free(prompt);

            targets[player_index] = try getIntInput(
                stdout,
                stdin,
                prompt,
                isValidTarget,
                "Please input a number between 1 and 13 (inclusive).",
            );
        }

        var game_points: [NUM_PLAYERS]GamePoints = undefined;
        // Get hands won and calculate points
        for (0..NUM_PLAYERS) |i| {
            const player_index = (game_num + i) % NUM_PLAYERS;
            const target = targets[player_index];

            const prompt = try std.fmt.allocPrint(allocator, "Please input number of hands won by {s} = ", .{players[player_index].name});
            defer allocator.free(prompt);

            const hands_won = try getIntInput(
                stdout,
                stdin,
                prompt,
                isValidHands,
                "Please input valid number of hands",
            );

            if (hands_won < target) {
                players[player_index].points -= target;
                game_points[player_index] = .{
                    .target = try std.fmt.allocPrint(allocator, "({d})", .{target}),
                    .overtricks = "",
                };
            } else {
                players[player_index].points += target;
                players[player_index].overtricks += hands_won - target;
                game_points[player_index] = .{
                    .target = try std.fmt.allocPrint(allocator, "{d}", .{target}),
                    .overtricks = try std.fmt.allocPrint(allocator, "{d}", .{hands_won - target}),
                };
            }
        }

        try games.append(.{ .points = game_points });

        // Display points
        try stdout.print("\nS.N.", .{});
        for (players) |player| {
            try stdout.print("\t{s}", .{player.name});
        }
        try stdout.print("\n", .{});

        for (0..game_num + 1) |j| {
            try stdout.print("{d}.", .{j + 1});
            for (0..NUM_PLAYERS) |p| {
                const points = games.items[j].points[p];
                try stdout.print("\t{s}.{s}", .{ points.target, points.overtricks });
            }
            try stdout.print("\n", .{});
        }

        try stdout.print("{s}\n", .{"-" ** 40});
        try stdout.print("Total", .{});
        for (players) |player| {
            try stdout.print("\t{d}.{d}", .{ player.points, player.overtricks });
        }
        try stdout.print("\n", .{});
    }

    // Cleanup
    for (players) |player| {
        allocator.free(player.name);
    }
    for (games.items) |game| {
        for (game.points) |points| {
            allocator.free(points.target);
            if (points.overtricks.len > 0) {
                allocator.free(points.overtricks);
            }
        }
    }
}

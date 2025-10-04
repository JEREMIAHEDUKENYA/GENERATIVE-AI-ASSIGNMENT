# Implementation file for EduGame sliding puzzle object

import random;
import time;

obj EduGame {
    has grid: list = [];
    has message: str = "";
    has moves: int = 0;
    has start_time: float = 0;
    has last_msg: str = "";
    has history: list = [];
    has best_moves: int = 0;
    has best_time: int = 0;
    def shuffle_cells() {
    cells = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,None,None];
        # keep shuffling until we get a solvable board
        while True {
            random.shuffle(cells);
            if self.is_solvable(cells) {
                break;
            }
        }
        self.grid = [];
        for i in range(4) {
            row = [];
            for j in range(4) {
                row.append(cells[i * 4 + j]);
            }
            self.grid.append(row);
        }
    }

    def is_solvable(flat_list: list) {
    # Count inversions ignoring the empty (None)
        inversions = 0;
        for i in range(len(flat_list)) {
            for j in range(i + 1, len(flat_list)) {
                if flat_list[i] != None and flat_list[j] != None and flat_list[i] > flat_list[j] {
                    inversions = inversions + 1;
                }
            }
        }
    # find blank index and compute row from bottom (1-based)
        blank_index = 0;
        for i in range(len(flat_list)) {
            if flat_list[i] == None {
                blank_index = i;
                break;
            }
        }
        blank_row_from_bottom = 4 - (blank_index // 4);
        # For even grid width (4): puzzle is solvable when
        # (blank_row_from_bottom is even) == (inversions is odd)
        return ((blank_row_from_bottom % 2) == 0) == ((inversions % 2) == 1);
    }

    def is_solved() {
        flat = [];
        for i in range(4) {
            for j in range(4) {
                flat.append(self.grid[i][j]);
            }
        }
        for i in range(14) {
            if flat[i] != i + 1 {
                return False;
            }
        }
        return flat[14] == None and flat[15] == None;
    }

    def move_cell(row: int, col: int) {
        if row < 0 or row >= 4 or col < 0 or col >= 4 {
            self.last_msg = "Invalid cell coordinates.";
                return False;
        }
        if self.grid[row][col] == None {
            self.last_msg = "Cannot move an empty cell.";
                return False;
        }
        directions = [[0,1],[1,0],[0,-1],[-1,0]];
        for idx in range(4) {
            dr = directions[idx][0];
            dc = directions[idx][1];
            nr = row + dr;
            nc = col + dc;
            if nr >= 0 and nr < 4 and nc >= 0 and nc < 4 {
                    if self.grid[nr][nc] == None {
                    self.grid[nr][nc] = self.grid[row][col];
                    self.grid[row][col] = None;
                        return True;
                }
            }
        }
        self.last_msg = "No adjacent empty cell to move.";
        return False;
    }

    def move_tile_by_number(tile_num: int) {
        for i in range(4) {
            for j in range(4) {
                if self.grid[i][j] == tile_num {
                    # save previous state for undo
                    self.push_history();
                    success = self.move_cell(i, j);
                    if success {
                        # count the move and set friendly message
                        self.moves = self.moves + 1;
                        self.last_msg = "Moved tile " + str(tile_num);
                        return True;
                    }
                    return False;
                }
            }
        }
        self.last_msg = "Tile not found.";
            return False;
    }

    def push_history() {
        # store a deep copy of current grid (list of lists)
        state = [];
        for r in range(4) {
            row_copy = [];
            for c in range(4) {
                row_copy.append(self.grid[r][c]);
            }
            state.append(row_copy);
        }
        self.history.append(state);
        # limit history to last 20 moves
        if len(self.history) > 20 {
            # drop oldest
            self.history.pop(0);
        }
    }

    def undo() {
        if len(self.history) == 0 {
            self.last_msg = "Nothing to undo.";
            return False;
        }
        prev = self.history.pop();
        self.grid = [];
        for r in range(4) {
            row_copy = [];
            for c in range(4) {
                row_copy.append(prev[r][c]);
            }
            self.grid.append(row_copy);
        }
        if self.moves > 0 {
            self.moves = self.moves - 1;
        }
        self.last_msg = "Undid previous move.";
        return True;
    }

    def move_blank_direction(dir: str) {
        # find blank (None)
        br = -1; bc = -1;
        for i in range(4) {
            for j in range(4) {
                if self.grid[i][j] == None {
                    br = i; bc = j;
                    break;
                }
            }
            if br != -1 {
                break;
            }
        }
        dr = 0; dc = 0;
        if dir == "w" {
            dr = -1; dc = 0;
        } elif dir == "s" {
            dr = 1; dc = 0;
        } elif dir == "a" {
            dr = 0; dc = -1;
        } elif dir == "d" {
            dr = 0; dc = 1;
        } else {
            return False;
        }
        nr = br + dr; nc = bc + dc;
        if nr < 0 or nr >= 4 or nc < 0 or nc >= 4 {
            self.last_msg = "Cannot move blank that direction.";
            return False;
        }
        # save state for undo
        self.push_history();
        # swap blank with neighbor
        self.grid[br][bc] = self.grid[nr][nc];
        self.grid[nr][nc] = None;
        self.moves = self.moves + 1;
        self.last_msg = "Moved blank " + dir;
        return True;
    }

    def reset_game() {
        self.shuffle_cells();
        self.message = "";
        # initialize status-tracking fields
        self.moves = 0;
        self.start_time = time.time();
        self.last_msg = "";
        # load best scores if available
        self.load_best_scores();
    }

    def load_best_scores() {
        try {
            import os, json;
            path = "best_scores.json";
            if os.path.exists(path) {
                f = open(path, "r");
                data = json.load(f);
                f.close();
                if data.get("moves") {
                    self.best_moves = data.get("moves");
                }
                if data.get("time") {
                    self.best_time = data.get("time");
                }
            }
        } except Exception as e {
            # ignore file errors
        }
    }

    def save_best_scores() {
        try {
            import json;
            data = {"moves": self.best_moves, "time": self.best_time};
            f = open("best_scores.json", "w");
            json.dump(data, f);
            f.close();
        } except Exception as e {
            # ignore file errors
        }
    }

    def print_instructions() {
        print("Instructions:");
        print(" - Enter a tile NUMBER to move it (e.g. '7').");
        print(" - Or use WASD to slide the blank: w/up s/down a/left d/right.");
        print(" - 'u' undo, 'r' reset, 'h' help, 'q' quit.");
    }

    def print_grid() {
        # Clear the terminal screen so we only show one grid
        # ANSI escape: move cursor home and clear screen
        print("\033[H\033[J");
        print("    0   1   2   3");
        print("  +---+---+---+---+");
        for i in range(4) {
            row_str = str(i) + " |";
            for j in range(4) {
                val = self.grid[i][j];
                cell_str = "";
                        if val != None {
                    if val < 10 {
                        cell_str = " " + str(val);
                    } else {
                        cell_str = str(val);
                    }
                } else {
                    cell_str = "  ";
                }
                row_str = row_str + " " + cell_str + " |";
            }
            print(row_str);
            print("  +---+---+---+---+");
        }
        # Status line: moves, elapsed time, last message
        elapsed = int(time.time() - self.start_time);
        print("Moves:", self.moves, "  Time:", elapsed, "s");
        if self.last_msg != "" {
            print("Status:", self.last_msg);
        }
        # show best scores if available
        if self.best_moves > 0 {
            print("Best Moves:", self.best_moves, " Best Time:", self.best_time, "s");
        }
    }
}

with entry {
    game = EduGame();
    game.reset_game();
    print("Welcome to the 4x4 Sliding Puzzle!");
    print("Rearrange the numbers in order by sliding tiles into empty spaces.");
    game.print_grid();
    # Print instructions after drawing the grid so they aren't cleared by the grid redraw.
    game.print_instructions();

    while True {
        if game.is_solved() {
            elapsed = int(time.time() - game.start_time);
            print("Congratulations, you solved the puzzle!");
            print("Moves:", game.moves, " Time:", elapsed, "s");
            # check best score
            improved = False;
            if game.best_moves == 0 or game.moves < game.best_moves {
                game.best_moves = game.moves;
                improved = True;
            }
            if game.best_time == 0 or elapsed < game.best_time {
                game.best_time = elapsed;
                improved = True;
            }
            if improved {
                game.save_best_scores();
                print("New best score! Saved to best_scores.json");
            }
            break;
        }
    # show prompt and read input
    print("Enter tile or command (h/r/u/w/a/s/d/r/q): ");
    move = input();
        if move == "q" {
            print("Game exited.");
            break;
        }
        if move == "h" {
            game.print_instructions();
            continue;
        }
        if move == "r" {
            game.reset_game();
            game.print_grid();
            continue;
        }
        if move == "u" {
            success = game.undo();
            if success {
                game.print_grid();
            }
            continue;
        }
        # WASD control for moving the blank
        if move in ["w","a","s","d"] {
            success = game.move_blank_direction(move);
            if success {
                game.print_grid();
            }
            continue;
        }
        if not move.isdigit() {
            print("Invalid input. Please enter a tile number.");
            continue;
        }
        tile_num = int(move);
        success = game.move_tile_by_number(tile_num);
        # Only redraw the grid when a move actually changed the board.
        if success {
            game.print_grid();
        }
    }
}
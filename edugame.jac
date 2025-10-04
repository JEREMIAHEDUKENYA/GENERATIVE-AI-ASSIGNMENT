"""Interactive 4x4 Sliding Puzzle Game - Move by Tile Number (Jac, Table UI)"""

import random;

obj SlidingPuzzle {
    has grid: list = [];
    has message: str = "";

    def shuffle_cells {
        cells = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,None,None];
        random.shuffle(cells);
        self.grid = [];
        for i in range(4) {
            row = [];
            for j in range(4) {
                row.append(cells[i * 4 + j]);
            }
            self.grid.append(row);
        }
    }

    def is_solved {
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
            print("Invalid cell coordinates.");
            return False;
        }
        if self.grid[row][col] == None {
            print("Cannot move an empty cell.");
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
        print("No adjacent empty cell to move.");
        return False;
    }

    def move_tile_by_number(tile_num: int) {
        for i in range(4) {
            for j in range(4) {
                if self.grid[i][j] == tile_num {
                    return self.move_cell(i, j);
                }
            }
        }
        print("Tile not found.");
        return False;
    }

    def reset_game {
        self.shuffle_cells();
        self.message = "";
    }

    def print_grid {
        print("\n    0   1   2   3");
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
    }
}

with entry {
    game = SlidingPuzzle();
    game.reset_game();

    print("Welcome to the 4x4 Sliding Puzzle!");
    print("Rearrange the numbers in order by sliding tiles into empty spaces.");
    print("Enter the NUMBER of the tile you want to move (e.g. '7'). Type 'q' to quit.");
    game.print_grid();

    while True {
        if game.is_solved() {
            print("Congratulations, you solved the puzzle! 🎉");
            break;
        }
        move = input("Enter tile number to move (e.g. '7'), or q to quit: ");
        if move == "q" {
            print("Game exited.");
            break;
        }
        if not move.isdigit() {
            print("Invalid input. Please enter a tile number.");
            continue;
        }
        tile_num = int(move);
        success = game.move_tile_by_number(tile_num);
        game.print_grid();
    }
}
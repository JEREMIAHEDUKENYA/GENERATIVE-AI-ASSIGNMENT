import random;
import time;
import from byllm.llm { Model }

glob llm = Model(model_name="gpt-4o", verbose=False);

"""Provide a fun, context-aware hint for the sliding puzzle."""
def give_hint(grid: list, moves: int) -> str by llm();

obj EduGame {
    has grid: list = [];
    has moves: int = 0;

    def shuffle_cells() {
        cells = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,None,None];
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
        inversions = 0;
        for i in range(len(flat_list)) {
            for j in range(i + 1, len(flat_list)) {
                if flat_list[i] != None and flat_list[j] != None and flat_list[i] > flat_list[j] {
                    inversions = inversions + 1;
                }
            }
        }
        blank_index = 0;
        for i in range(len(flat_list)) {
            if flat_list[i] == None {
                blank_index = i;
                break;
            }
        }
        blank_row_from_bottom = 4 - (blank_index // 4);
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
}

def move_blank(g: EduGame, dir: str) {
    br = -1; bc = -1;
    for i in range(4) {
        for j in range(4) {
            if g.grid[i][j] == None {
                br = i; bc = j;
                break;
            }
        }
        if br != -1 { break; }
    }
    dr = 0; dc = 0;
    if dir == "w" { dr = -1; dc = 0; }
    elif dir == "s" { dr = 1; dc = 0; }
    elif dir == "a" { dr = 0; dc = -1; }
    elif dir == "d" { dr = 0; dc = 1; }
    nr = br + dr; nc = bc + dc;
    if nr < 0 or nr >= 4 or nc < 0 or nc >= 4 { return False; }
    g.grid[br][bc] = g.grid[nr][nc];
    g.grid[nr][nc] = None;
    return True;
}

def move_tile(g: EduGame, tile_num: int) {
    for i in range(4) {
        for j in range(4) {
            if g.grid[i][j] == tile_num {
                dirs = [[0,1],[1,0],[0,-1],[-1,0]];
                for d in dirs {
                    nr = i + d[0]; nc = j + d[1];
                    if nr >= 0 and nr < 4 and nc >= 0 and nc < 4 {
                        if g.grid[nr][nc] == None {
                            g.grid[nr][nc] = g.grid[i][j];
                            g.grid[i][j] = None;
                            return True;
                        }
                    }
                }
                print("No adjacent empty cell to move.");
                return False;
            }
        }
    }
    print("Tile not found.");
    return False;
}

walker SlidingPuzzleLLM {

    with entry {
        game = EduGame();
        game.shuffle_cells();
        print("Welcome to the AI-Enhanced Jac Sliding Puzzle!\n");

        while True {
            # Show current grid
            for i in range(4) {
                row_str = "";
                for j in range(4) {
                    val = game.grid[i][j];
                    cell_str = "  " if val == None else str(val).rjust(2, " ");
                    row_str = row_str + cell_str + " ";
                }
                print(row_str);
            }
            print("Moves:", game.moves);

            # Check solved
            if game.is_solved() {
                print("Congratulations, you solved the puzzle!");
                break;
            }

            print("Enter tile to move or WASD for blank (q to quit): ");
            move = input();
            if move == "q" {
                print("Game exited.");
                break;
            }
            moved = False;

            # WASD blank move
            if move in ["w", "a", "s", "d"] {
                moved = move_blank(game, move);
            } elif move.isdigit() {
                moved = move_tile(game, int(move));
            } else {
                print("Invalid input.");
            }

            if moved {
                game.moves = game.moves + 1;
                hint = give_hint(game.grid, game.moves);
                print("AI Hint:", hint);
            }
        }
    }
}

with entry {
    root spawn SlidingPuzzleLLM();
}
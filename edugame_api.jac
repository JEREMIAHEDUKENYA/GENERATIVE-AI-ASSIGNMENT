import random;
import time;
import os;
import json;

obj EduGame {
    // ... (same methods as your current EduGame object) ...
    // Copy all your methods here unchanged.
}

walker EduGameAPI {
    has game: EduGame = None;

    // Create new game
    def start_game() {
        self.game = EduGame();
        self.game.reset_game();
        return {
            "message": "New game started.",
            "grid": self.game.grid,
            "moves": self.game.moves
        };
    }

    // Get current game state
    def get_state() {
        if self.game == None {
            return {"error": "No game started."};
        }
        return {
            "grid": self.game.grid,
            "moves": self.game.moves,
            "last_msg": self.game.last_msg,
            "best_moves": self.game.best_moves,
            "best_time": self.game.best_time
        };
    }

    // Move tile by number
    def move_tile(tile_num: int) {
        if self.game == None {
            return {"error": "No game started."};
        }
        success = self.game.move_tile_by_number(tile_num);
        return {
            "success": success,
            "grid": self.game.grid,
            "last_msg": self.game.last_msg,
            "moves": self.game.moves
        };
    }

    // Move blank by direction
    def move_blank(dir: str) {
        if self.game == None {
            return {"error": "No game started."};
        }
        success = self.game.move_blank_direction(dir);
        return {
            "success": success,
            "grid": self.game.grid,
            "last_msg": self.game.last_msg,
            "moves": self.game.moves
        };
    }

    // Undo last move
    def undo() {
        if self.game == None {
            return {"error": "No game started."};
        }
        success = self.game.undo();
        return {
            "success": success,
            "grid": self.game.grid,
            "last_msg": self.game.last_msg,
            "moves": self.game.moves
        };
    }

    // Check if solved
    def is_solved() {
        if self.game == None {
            return {"error": "No game started."};
        }
        solved = self.game.is_solved();
        return {"solved": solved};
    }
}

with entry {
    spawn EduGameAPI at root;
}
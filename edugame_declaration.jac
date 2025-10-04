# Declaration file for EduGame sliding puzzle object

obj EduGame {
    has grid: list = [];
    has message: str = "";

    def shuffle_cells();
    def is_solved();
    def move_cell(row: int, col: int);
    def move_tile_by_number(tile_num: int);
    def reset_game();
    def print_grid();
}
# Represents at tic-tac-toe board
class Board:

    # Initializes the board with either the specified or default state
    # Note: The board state is represented as nine character string
    # Note: composed of "X", "O", or "-" (for an empty space)
    def __init__(self, state="---------"):
        self.empty = "-"
        self.spaces = list(state)

        # Lines represent each horizontal, vertical, or diagonal win line
        self.lines = (
            (0, 1, 2),
            (3, 4, 5),
            (6, 7, 8),
            (0, 3, 6),
            (1, 4, 7),
            (2, 5, 8),
            (0, 4, 8),
            (2, 4, 6))

    # Returns true if the board is empty, else false
    def is_empty(self) -> bool:
        for space in self.spaces:
            if space != self.empty:
                return False
        return True

    # Returns true if the board is full, else false
    def is_full(self) -> bool:
        for space in self.spaces:
            if space == self.empty:
                return False
        return True

    # Returns true if the specified space is open, else false
    def is_open_space(self, space: int) -> bool:
        return self.spaces[space] == "-"

    # Returns a list of all open spaces on the board
    def get_open_spaces(self) -> list:
        open_spaces = []
        for i in range(len(self.spaces)):
            if self.spaces[i] == "-":
                open_spaces.append(i)
        return open_spaces

    # Marks a space with the appropriate mark (i.e. "X" or "O")
    def mark_space(self, space: int, mark: str):
        if not self.is_open_space(space):
            raise Exception("Move is not valid.")

        self.spaces[space] = mark

    # Returns true if a win currently exists, else false
    def has_win(self, mark) -> bool:
        for line in self.lines:
            if self.spaces[line[0]] == mark \
                    and self.spaces[line[1]] == mark \
                    and self.spaces[line[2]] == mark:
                return True

        return False

    # Returns a deep copy of the board in its current state
    def copy(self):
        state = str().join(self.spaces)
        new_board = Board(state)
        return new_board

    # Returns a display-friendly grid of the numbered space indexes
    def get_space_indexes(self) -> str:
        return "0 1 2\n3 4 5\n6 7 8\n"

    # Returns a display-friendly grid of the current state of the board
    def __str__(self) -> str:
        return \
            f"{self.spaces[0]} {self.spaces[1]} {self.spaces[2]}\n" + \
            f"{self.spaces[3]} {self.spaces[4]} {self.spaces[5]}\n" + \
            f"{self.spaces[6]} {self.spaces[7]} {self.spaces[8]}\n"

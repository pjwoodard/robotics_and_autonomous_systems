# Import libraries
from board import Board


# Represents an abstract tic-tac-toe player
class Player:

    # Initialize the player
    def __init__(self, number):
        self.number = number
        self.mark = "X" if number == 1 else "O"
        self.opponent_mark = "O" if number == 1 else "X"

    # Get the player's next move
    # Note: This is an abstract method to be implemented in the player subclass
    def get_next_move(self, board: Board) -> int:
        pass

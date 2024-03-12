# Import libraries
from player import Player
from board import Board


# Represents a human player interacting via the console
class HumanPlayer(Player):

    # Get the human player's next move
    def get_next_move(self, board: Board) -> int:

        # Set a flag to determine if a move is valid or not
        is_valid_move = False

        # Loop until a valid move is chosen
        while not is_valid_move:

            # Get the human player's next move by asking via console input
            space = int(input(f"Player {self.number}, place your mark [0-8]: "))

            # Determine if the move is valid given the state of the board
            is_valid_move = board.is_open_space(space)

            # If the move is not valid, display a message to the user
            if not is_valid_move:
                print(f"{space} is an invalid move.")

        # Return the valid move that the human player selected
        return space

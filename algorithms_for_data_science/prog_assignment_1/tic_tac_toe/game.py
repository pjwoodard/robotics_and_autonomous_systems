# Import libraries
from board import Board
from player import Player


# Represents a game of tic-tac-toe
class Game:

    # Initializes the game of tic-tac-toe
    def __init__(self, player1: Player, player2: Player):
        self.board = Board()
        self.player1 = player1
        self.player2 = player2
        self.players = [player1, player2]

    # Plays the game and returns the results
    # A "1" means player 1 wins, "2" means player 2 wins; "0" means a draw
    def play(self) -> int:

        # Display the game start messages and a grid of numbered space indexes
        print("Starting a new game of tic-tac-toe.")
        print("Spaces are numbered as follows:")
        print(self.board.get_space_indexes())

        # Initialize the number of turns to 1
        turn = 1

        # Loop until there is a win, loss, or draw
        while True:

            # Loop through each player (i.e. alternate players)
            for player in self.players:

                # Get the current player's next move
                move = player.get_next_move(self.board)

                # Mark the board with their chosen move
                self.board.mark_space(move, player.mark)

                # Display the players move and the current board state
                print(f"Player {player.number} chooses space {move}.")
                print(str(self.board))

                # If there is a winner, display and return the winner
                if self.board.has_win(player.mark):
                    print(f"Player {player.number} wins!\n")
                    return player.number

                # On the 9th turn, all spaces are filled, so return a draw
                if turn == 9:
                    print("Game is a draw.\n")
                    return None

                # Increment the turn counter
                turn += 1

# Import libraries
# from random_player import RandomPlayer
# from conditional_player import ConditionalPlayer
from utility_player import UtilityPlayer
# from minimax_player import MinimaxPlayer
# from alpha_beta_player import AlphaBetaPlayer
from human_player import HumanPlayer
from game import Game

# Set the players for the game
# Note: Change these players to test different agents
player1 = HumanPlayer(1)
player2 = UtilityPlayer(2)

# Loop until the user chooses to exit the program
while True:

    # Create a new game using the two players
    game = Game(player1, player2)

    # Play the game to it's conclusion
    game.play()

    # Ask the user if they want to continue
    choice = input("Play another game? Y/N: ")

    # Exit the program if the user doesn't want to play anymore
    if choice != "Y":
        break





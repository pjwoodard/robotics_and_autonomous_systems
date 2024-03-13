# Import libraries
from player import Player
from board import Board


# Represents a tic-tac-toe agent that evaluates moves using conditional logic
class GoalPlayer(Player):

    def get_decisive_move(self, board: Board) -> int:
        # Check if we have a win, take it
        for line in board.lines:
            num_marks = sum([board.spaces[space] == self.mark for space in line])
            # If there are 2 of our marks in a line, take it
            if num_marks == 2:
                for space in line:
                    if board.is_open_space(space):
                        return space

        # Check if the opponent has a win, block it
        for line in board.lines:
            num_marks = sum([board.spaces[space] == self.opponent_mark for space in line])
            if num_marks == 2:
                for space in line:
                    if board.is_open_space(space):
                        return space

        return None
    
    def get_non_decisive_move(self, board: Board) -> int:
        # Are any of the corners open?
        corners = [0, 2, 6, 8]
        for corner in corners:
            if board.is_open_space(corner):
                return corner
            else:
                # Play the center if one of the corners is taken by our opponent
                if board.is_open_space(4):
                    return 4

        # Is the center open?
        if board.is_open_space(4):
            return 4
        
        # Take the first open space 
        return board.get_open_spaces()[0]

    # Returns the next move given the current board state
    def get_next_move(self, board: Board) -> int:
        # Take care of decisive moves
        move = self.get_decisive_move(board)
        if move is not None:
            return move

        # Figure out what sort of non-decisive move to make
        move = self.get_non_decisive_move(board)
        return move

# Import libraries
from board import Board
from player import Player 


# Represents a tic-tac-toe agent evaluating moves with a utility function
# Note: this agent inherits from a conditional player
# Note: it uses it's conditional logic for making decisive moves
class UtilityPlayer(Player):

    # Gets the next move using an utility function
    # and conditional logic for decisive moves

    def __init__(self, number):
        super().__init__(number)

    def is_line_empty(self, board: Board, line: list[int]) -> bool:
        return all([board.spaces[space] == "-" for space in line])
    
    def is_line_full(self, board: Board, line: list[int]) -> bool:
        return all([board.spaces[space] != "-" for space in line])

    def get_utility_of_lines(self, board: Board) -> list[int]:
        utilities = []
        for line in board.lines:
            if self.is_line_empty(board, line):
                utilities.append(0)
            elif self.is_line_full(board, line):
                utilities.append(-10)
            else:
                utilities.append(self.get_line_utility(board, line))

        return utilities

    def get_utility_of_spaces(self, board: Board, utilities_of_lines: list[int]) -> list:
        line_utilities = []

        for index, _ in enumerate(board.spaces):
            utility = 0
            for line_num, line in enumerate(board.lines):
                print(f"Index: {index}, Line: {line}, Open Spaces: {board.get_open_spaces()}")
                if index in line and index in board.get_open_spaces():
                    print(f"Adding utility for line {line_num} at index {index}")
                    utility += utilities_of_lines[line_num]
            if index not in board.get_open_spaces():
                utility = -99
            line_utilities.append(utility)

        return line_utilities 


    def get_line_utility(self, board: Board, line: list[int]) -> int:
        """
        Get the utility of a line for the player
        """
        agent_marks = 0
        opponent_marks = 0

        if self.number == 1:
            agent_mark = "X"
            opponent_mark = "O"
        else:
            agent_mark = "O"
            opponent_mark = "X"

        for space in line:
            if board.spaces[space] == agent_mark:
                agent_marks += 1
            elif board.spaces[space] == opponent_mark:
                opponent_marks += 1

        # I took this utility function from the pseudocode rather than using the one in the assignment
        # It just made it easier to test with the existing unit test cases and we were told on Thursday it ultimately
        # didn't matter which utility function we used
        line_utility = 3 * agent_marks - opponent_marks
        return line_utility

    def get_next_move(self, board: Board) -> int:
        # Check if we have a win, take it
        for line in board.lines:
            # If there are 2 of our marks in a line, take it
            if self.get_line_utility(board, line) == 6:
                for space in line:
                    if board.is_open_space(space):
                        print(f"Winning space {space}")
                        return space

        # Check if the opponent has a win, block it
        for line in board.lines:
            if self.get_line_utility(board, line) == -2:
                for space in line:
                    if board.is_open_space(space):
                        print(f"Blocking space {space}")
                        return space

        # Evaluate each open board location for utility
        lines = self.get_utility_of_lines(board)
        spaces = self.get_utility_of_spaces(board, lines)
        best_moves = [move for move, x in enumerate(spaces) if x == max(spaces)]
        print(f"Best Moves: {best_moves}")

        # Take the first best move, in this case the moves are equal
        return best_moves[0]

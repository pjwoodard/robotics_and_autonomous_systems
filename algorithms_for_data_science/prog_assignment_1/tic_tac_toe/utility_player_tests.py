import unittest
from parameterized import parameterized
from utility_player import UtilityPlayer
from board import Board


class UtilityPlayerTests(unittest.TestCase):
    @parameterized.expand([
        ["---------", 0],
        ["X--------", 5],
        ["OX-X-----", 8],
        ["X-X------", 1],
        ["X-------X", 4],
        ["X-----X-O", 3],
        ["X-OO--X--", 5]
    ])
    def test_get_next_move(self, state, expected_move):
        board = Board(state)
        player = UtilityPlayer(2)
        result = player.get_next_move(board)
        self.assertEqual(expected_move, result)

    @parameterized.expand([
        ["---XXXXXX", [0, -10, -10, 6, 6, 6, 6, 6]]
    ])
    def test_get_utility_of_lines(self, state, expected):
        board = Board(state)
        player = UtilityPlayer(1)
        result = player.get_utility_of_lines(board)
        self.assertEqual(expected, result)

    @parameterized.expand([
        ["---XOXOXO", [0, 1, 2], True],
        ["-XO-XO-XO", [0, 3, 6], True],
        ["-XOX-XOX-", [0, 4, 8], True],
        ["X--XOXOXO", [0, 1, 2], False],
        ["-XO-XOXOX", [0, 3, 6], False],
        ["-XOXOXOX-", [0, 4, 8], False],

    ])
    def test_is_line_empty(self, state, line, expected):
        board = Board(state)
        player = UtilityPlayer(1)
        result = player.is_line_empty(board, line)
        self.assertEqual(expected, result)

    @parameterized.expand([
        ["X0X------", [0, 1, 2], True],
        ["X--0--X--", [0, 3, 6], True],
        ["X---O---X", [0, 4, 8], True],
        ["-X-XOXXOX", [0, 1, 2], False],
        ["-XO-XOXOX", [0, 3, 6], False],
        ["-XOXOXOX-", [0, 4, 8], False],

    ])
    def test_is_line_full(self, state, line, expected):
        board = Board(state)
        player = UtilityPlayer(1)
        result = player.is_line_full(board, line)
        self.assertEqual(expected, result)

    @parameterized.expand([
        ["X--------", [0, 1, 2], 3],
        ["XX-------", [0, 1, 2], 6],
        ["XO-------", [0, 1, 2], 2],
    ])
    def test_get_line_utility_for_player_1(self, state, line, expected):
        board = Board(state)
        player = UtilityPlayer(1)
        result = player.get_line_utility(board, line)
        self.assertEqual(expected, result)

    @parameterized.expand([
        ["O--------", [0, 1, 2], 3],
        ["OO-------", [0, 1, 2], 6],
        ["OX-------", [0, 1, 2], 2],
    ])
    def test_get_line_utility_for_player_2(self, state, line, expected):
        board = Board(state)
        player = UtilityPlayer(2)
        result = player.get_line_utility(board, line)
        self.assertEqual(expected, result)

    @parameterized.expand([
        [[1, 0, 0, 0, 0, 0, 0, 0], [1, 1, 1, 0, 0, 0, 0, 0, 0]],
        [[0, 0, 0, 1, 0, 0, 0, 0], [1, 0, 0, 1, 0, 0, 1, 0, 0]],
        [[0, 0, 0, 0, 0, 0, 1, 0], [1, 0, 0, 0, 1, 0, 0, 0, 1]],
        [[1, 0, 0, 1, 0, 0, 1, 0], [3, 1, 1, 1, 1, 0, 1, 0, 1]]
    ])
    def test_get_utility_of_spaces(self, utility_of_lines, utility_of_spaces):
        board = Board()
        player = UtilityPlayer(1)
        result = player.get_utility_of_spaces(board, utility_of_lines)
        self.assertEqual(utility_of_spaces, result)

    @parameterized.expand([
        ["X--------", [-99, 0, 0, 0, 0, 0, 0, 0, 0]],
        ["O--------", [-99, 0, 0, 0, 0, 0, 0, 0, 0]],
        ["X-------O", [-99, 0, 0, 0, 0, 0, 0, 0, -99]]
    ])
    def test_get_utility_of_spaces_restricts_occupied_spaces(self, state, expected_utility_of_spaces):
        board = Board(state)
        player = UtilityPlayer(1)
        utility_of_lines = [0, 0, 0, 0, 0, 0, 0, 0]
        result = player.get_utility_of_spaces(board, utility_of_lines)
        self.assertEqual(expected_utility_of_spaces, result)


if __name__ == '__main__':
    unittest.main()

import unittest
from parameterized import parameterized
from goal_player import GoalPlayer 
from board import Board


class GoalPlayerTests(unittest.TestCase):
    @parameterized.expand([
        ["---------", 0],
        ["X--------", 4],
        ["X-X------", 1]
    ])
    def test_get_next_move(self, state, expected_move):
        board = Board(state)
        player = GoalPlayer(2)
        result = player.get_next_move(board)
        self.assertEqual(expected_move, result)

    @parameterized.expand([
        ["-XX------", 0],
        ["---X--X--", 0],
        ["----X---X", 0],
        ["X-X------", 1],
        ["----X--X-", 1],
        ["XX-------", 2],
        ["-----X--X", 2],
        ["----X-X--", 2],
        ["----XX---", 3],
        ["X-----X--", 3],
        ["---X-X---", 4],
        ["-X-----X-", 4],
        ["X-------X", 4],
        ["--X---X--", 4],
        ["--X-----X", 5],
        ["---XX----", 5],
        ["-------XX", 6],
        ["X--X-----", 6],
        ["--X-X----", 6],
        ["------X-X", 7],
        ["-X--X----", 7],
        ["------XX-", 8],
        ["--X--X---", 8],
        ["X---X----", 8],
        ["---------", None],
        ["XOX------", None]

    ])
    def test_get_decisive_move_takes_win(self, state, expected_move):
        board = Board(state)
        player = GoalPlayer(2)
        result = player.get_decisive_move(board)
        self.assertEqual(expected_move, result)

    def test_get_decisive_move_blocks_win(self):
        board = Board("-XX------")
        player = GoalPlayer(1)
        result = player.get_decisive_move(board)
        self.assertEqual(0, result)

    @parameterized.expand([
        ["---------", 0],
        ["X--------", 4],
        ["-X--X----", 0],
        ["X---X----", 2],
        ["X-X-X----", 6],
        ["X-X-X-X--", 8],
        ["X-X-X-X-X", 1],
        ["XXX-X-X-X", 3],
        ["XXXXX-X-X", 5],
        ["XXXXXXX-X", 7]
    ])
    def test_get_non_decisive_move(self, state, expected_move):
        board = Board(state)
        player = GoalPlayer(2)
        result = player.get_non_decisive_move(board)
        self.assertEqual(expected_move, result)


if __name__ == '__main__':
    unittest.main()

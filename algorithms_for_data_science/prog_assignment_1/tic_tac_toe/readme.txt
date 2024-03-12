Files:
 - tic_tac_toe.py - the main program to play a game of tic tac toe against an agent
 - experiment.py - a program to run a specified number of games with automated players for analysis
 - game.py - represents a game of tic tac toe played by two players
 - board.py - represents a tic tac toe board
 - player.py - represents an abstract player to be implemented by the following subclasses <below>
   - human_player.py - represents an human player who is prompted for input via the console
   - goal_player.py - A simple conditional player that goes for best moves based on the current board
   - utility_player.py - represents an automated agent who uses a utility function to evaluate moves
 - [class]_tests.py - contains unit tests for the corresponding classes:
      - Goal Player tests contain tests for our simple conditional player
      - Utility player tests contain tests for our utility function player

Notes:
  All unused files from the original file set posted were removed, this only contains the source that was used
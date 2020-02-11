# Word Puzzle Solver
A simple program to find words in a word puzzle

## File System
There are two folders in the program. The "code/" directory stores the code to solve puzzles written in both C and MIPS. The "data" directory stores the puzzle grid and the vocabulary used to solve the puzzle.

## Instructions to Play the Game
1. The program is executable in command line. You must go to the "code/" directory in command line and make sure "data/" and "code/" are in the same parent directory before running the program.
2. Different codes are used to solve different puzzles. "1dstrfind.s" and "1dstrfind.c" solve a word puzzle containing one line only. "2dstrfind.s" and "2dstrfind.c" solve any 2D word puzzle with horizontal, vertical and diagonal matches. "wraparound.c" and "wraparound.s" solve any 2D word puzzle with horizontal, vertical, diagonal and wraparound matches.
3. The program uses default puzzles and accepted vocabulary stored in "data/" directory. To customize puzzles and accepted vocabulary, simply replace the respective files in "data/".
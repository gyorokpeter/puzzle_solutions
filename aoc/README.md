# Advent of Code

This directory contains the solutions for all problems from [Advent of Code](https://adventofcode.com).

Some general self-imposed rules on the code:
* The solution must be a function that takes the input as a list of strings, which can be obtained by using `read0` on the downloaded input file. For puzzles where there is no downloaded input file, the parameter might be a single string or an integer - this is noted on the specific function.
  * The name of the function is `dXp1` and `dXp2` (for part 1 and 2 respectively) with X replaced by the day number.
  * In case there would be considerable code duplication between the two parts, the solution is instead a single `dX` function that takes either the part as an integer `1` or `2`, or any parameter specific to the puzzle, along with the input.
* No setting global variables (which locks out some clever golfed solutions). Helper functions may be named with a `dX` prefix or in the `.dX` namespace.
* No usage of `value` on a string to execute untrusted input.
* Code must run on the 32-bit version of 3.6 2019.04.02. (This is the last "no-strings-attached" free version.) That implies unfortunately not using the cool syntax introduced in 4.1.

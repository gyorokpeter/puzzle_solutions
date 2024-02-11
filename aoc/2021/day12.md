# Overview
Algorithms like BFS are not a natural fit to q so it's like some Python code with weird syntax.

Part 1 just enumerates all the paths with the filtering condition adjusted such that it discards
paths that have the same small letter twice but repeating capital letters are allowed.

Part 2 is similar but an extra field is added to the state that indicates whether the allowed
single repeat of a small letter node has beenn used or not.

A possible improvement could be to not store the full paths but a count for each set of visited
nodes, using a phantom node to simulate the repeated small node visit for part 2.

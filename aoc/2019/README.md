This directory contains the solutions for [Advent of Code 2019](https://adventofcode.com/2019).

| Title                                     | Hint                                    | Code            | Explanation             |
|-------------------------------------------|-----------------------------------------|-----------------|-------------------------|
| Day 1: The Tyranny of the Rocket Equation |                                         | [Code](day1.q)  | [Explanation](day1.md)  |
| Day 2: 1202 Program Alarm                 | Intcode basic                           | [Code](day2.q)  | [Explanation](day2.md)  |
| Day 3: Crossed Wires                      | Path tracing                            | [Code](day3.q)  | [Explanation](day3.md)  |
| Day 4: Secure Container                   | Digit constraint matching               | [Code](day4.q)  | [Explanation](day4.md)  |
| Day 5: Sunny with a Chance of Asteroids   | **RE** Intcode intermediate             | [Code](day5.q)  | [Explanation](day5.md)  |
| Day 6: Universal Orbit Map                | DAG path search                         | [Code](day6.q)  | [Explanation](day6.md)  |
| Day 7: Amplification Circuit              | **RE** Intcode parallelism              | [Code](day7.q)  | [Explanation](day7.md)  |
| Day 8: Space Image Format                 | Image masking / OCR                     | [Code](day8.q)  | [Explanation](day8.md)  |
| Day 9: Sensor Boost                       | **RE** Intcode advanced                 | [Code](day9.q)  | [Explanation](day9.md)  |
| Day 10: Monitoring Station                | Ray casting                             | [Code](day10.q) | [Explanation](day10.md) |
| Day 11: Space Police                      | **RE** Intcode painting                 | [Code](day11.q) | [Explanation](day11.md) |
| Day 12: The N-Body Problem                | Gravity simulation                      | [Code](day12.q) | [Explanation](day12.md) |
| Day 13: Care Package                      | **RE** Intcode Breakout                 | [Code](day13.q) | [Explanation](day13.md) |
| Day 14: Space Stoichiometry               | Item crafting                           | [Code](day14.q) | [Explanation](day14.md) |
| Day 15: Oxygen System                     | **RE** Intcode mapping                  | [Code](day15.q) | [Explanation](day15.md) |
| Day 16: Flawed Frequency Transmission     | Matrix multiplication                   | [Code](day16.q) | [Explanation](day16.md) |
| Day 17: Set and Forget                    | **RE** Intcode path coverage            | [Code](day17.q) | [Explanation](day17.md) |
| Day 18: Many-Worlds Interpretation        | Pathfinding with keys/doors             | [Code](day18.q) | [Explanation](day18.md) |
| Day 19: Tractor Beam                      | **RE** Intcode area fitting             | [Code](day19.q) | [Explanation](day19.md) |
| Day 20: Donut Maze                        | Pathfinding on recursive map            | [Code](day20.q) | [Explanation](day20.md) |
| Day 21: Springdroid Adventure             | **RE** Intcode bot control (platformer) | [Code](day21.q) | [Explanation](day21.md) |
| Day 22: Slam Shuffle                      | Sequence manipulation                   | [Code](day22.q) | [Explanation](day22.md) |
| Day 23: Category Six                      | **RE** Intcode neural network           | [Code](day23.q) | [Explanation](day23.md) |
| Day 24: Planet of Discord                 | Cellular automaton on recursive map     | [Code](day24.q) | [Explanation](day24.md) |
| Day 25: Cryostasis                        | **RE** Intcode text adventure           | [Code](day25.q) | [Explanation](day25.md) |

* **RE** indicates that a reverse-engineered solution is included for this puzzle.

I used [genarch](../utils/README.md#genarch) to reverse engineer the intcode programs. In fact genarch grew out of
my initial intcode visualizer. The reverse engineered solutions take the `whitebox` suffix to the
solution function names. (I took the name from "white-box testing", which implies we can take
advantage of the internal structure of the program.)

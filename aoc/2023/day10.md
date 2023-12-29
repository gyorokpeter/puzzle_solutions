# Breakdown

Example input:
```q
x:();
x,:enlist".F----7F7F7F7F-7....";
x,:enlist".|F--7||||||||FJ....";
x,:enlist".||.FJ||||||||L7....";
x,:enlist"FJL7L7LJLJ||LJ.L-7..";
x,:enlist"L--J.L7...LJS7F-7L7.";
x,:enlist"....F-J..F7FJ|L7L7L7";
x,:enlist"....L7.F7||L7|.L7L7|";
x,:enlist".....|FJLJ|FJ|F7|.LJ";
x,:enlist"....FJL-7.||.||||...";
x,:enlist"....L---J.LJ.LJLJ...";
```

## Common
We define a neighbor map for the tiles (the coordinates in the order `r,c`):
```q
.d10.nm:()!();
.d10.nm[" "]:(0N 0N;0N 0N);
.d10.nm["."]:(0N 0N;0N 0N);
.d10.nm["|"]:(-1 0;1 0);
.d10.nm["-"]:(0 -1;0 1);
.d10.nm["L"]:(-1 0;0 1);
.d10.nm["J"]:(-1 0;0 -1);
.d10.nm["7"]:(1 0;0 -1);
.d10.nm["F"]:(1 0;0 1);
```

We find the coordinates of the `S` tile:
```q
q)start:first raze til[count x],/:'where each x="S";
q)start
4 12
```
We then figure out what kind of pipe it should be based on its four neighbors:
```q
q)nxts:start+/:(-1 0;0 1;1 0;0 -1);
q)nxts
3 12
4 13
5 12
4 11
q)x ./:nxts
"L7JJ"
q).d10.nm x ./:nxts
-1 0  0  1
1 0   0 -1
-1 0  0  -1
-1 0  0  -1
q)nxts+/:'.d10.nm x ./:nxts
2 12 3 13
5 13 4 12
4 12 5 11
3 11 4 10
q)start in/:nxts+/:'.d10.nm x ./:nxts
0110b
q)nxts where start in/:nxts+/:'.d10.nm x ./:nxts
4 13
5 12
q)(nxts where start in/:nxts+/:'.d10.nm x ./:nxts)-\:start
0 1
1 0
q)stt:(asc each .d10.nm)?asc(nxts where start in/:nxts+/:'.d10.nm x ./:nxts)-\:start
q)stt
"F"
q)x1:.[x;start;:;stt];
q)x1
".F----7F7F7F7F-7...."
".|F--7||||||||FJ...."
".||.FJ||||||||L7...."
"FJL7L7LJLJ||LJ.L-7.."
"L--J.L7...LJF7F-7L7."
"....F-J..F7FJ|L7L7L7"
"....L7.F7||L7|.L7L7|"
".....|FJLJ|FJ|F7|.LJ"
"....FJL-7.||.||||..."
"....L---J.LJ.LJLJ..."
```

To find the loop, we use a BFS (breadth first search). In traditional languages, BFS uses an actual queue data structure and pushes and pulls individual elements from it. In q the constant updating of lists when pushing and pulling elements would take too much time, so it's better to process the entire "queue" at the same time, usually also taking advantage of vector operations.

We initialize the distance matrix to an empty one. There are multiple ways to do this but one of them is to cast the map to long and add `0N` to it so every element becomes `0N`.
```q
d:0N+`long$x
```
We initialize the queue to contain only the start position and the step counter to 0:
```q
queue:enlist start;
step:0;
```
We iterate the BFS as long as there are elements in the queue:
```
while[count queue; ... ];
```
In each iteration, we first update the distance matrix at the positions in the queue to have the current step as the distance:
```q
d:.[;;:;step]/[d;queue]
```
We fetch the tile types for the queued positions from the (updated) map:
```q
ts:x1 ./:queue
```
We generate the lists of next nodes by looking up in the neighbor map:
```q
nxts:raze queue+/:'.d10.nm ts
```
We filter out alredy visited positions by checking if the distance matrix is null at that position. We also use `distinct` to avoid repeating positions.
```q
nxts:distinct nxts where null d ./:nxts
```
We increment the step counter and update the queue to the set of next nodes.
```q
step+:1
queue:nxts
```
Running the BFS on the example results in the following distance matrix:
```q
q)d
   59 60 61 62 63 64 69 68 61 60 51 50 43 42 41
   58 47 46 45 44 65 70 67 62 59 52 49 44 39 40
   57 48    42 43 66 69 66 63 58 53 48 45 38 37
55 56 49 50 41 40 67 68 65 64 57 54 47 46    36 35 34
54 53 52 51    39 38          56 55 0  1  20 21 22 33 32
            35 36 37       14 13 2  1  2  19 18 23 24 31 30
            34 33    19 18 15 12 3  4  3     17 16 25 26 29
               32 21 20 17 16 11 6  5  4  9  10 15    27 28
            30 31 22 23 24    10 7     5  8  11 14
            29 28 27 26 25    9  8     6  7  12 13
```

We call the function that performs this calculation `d10`. It will return the pair `(x1;d)`.

## Part 1
The answer is the maximum distance in the matrix.
```q
q)xd:d10 x;max max xd 1
70
```

## Part 2
We remove the non-loop pipe tiles from the map:
```q
q)d:0<=xd 1
q)d
01111111111111110000b
01111111111111110000b
01101111111111110000b
11111111111111011100b
11110110001111111110b
00001110011111111111b
00001101111111011111b
00000111111111111011b
00001111101101111000b
00001111101101111000b
q)m:"."^`char$32 or d*`int$xd 0
q)m
".F----7F7F7F7F-7...."
".|F--7||||||||FJ...."
".||.FJ||||||||L7...."
"FJL7L7LJLJ||LJ.L-7.."
"L--J.L7...LJF7F-7L7."
"....F-J..F7FJ|L7L7L7"
"....L7.F7||L7|.L7L7|"
".....|FJLJ|FJ|F7|.LJ"
"....FJL-7.||.||||..."
"....L---J.LJ.LJLJ..."
```
Instead of implementing "squeeze" logic, an alternative is to stretch out the map to double size, adding connecting pipe segments where necessary. Then a flood fill from the outside can find all the outside positions, leaving any unmarked positions to be inside.

To stretch the map horizontally, we add a horizontal pipe segment after every pipe segment that has a connection to the right according to the neighbor map. We also add an empty column on the left (there are no pipes on the right with an open right connection, so the stretching should already result in an empty column on the right).
```q
q)".-"m in\:where 0 1 in/:.d10.nm
".-----.-.-.-.--....."
"..---.........-....."
"....-.........-....."
"-.-.-.-.-...-..--..."
"---..-....-...--.-.."
"....--...-.-..-.-.-."
"....-..-...-...-.-.."
"......-.-..-..-...-."
"....-.--............"
"....----..-..-.-...."
q)m1:".",/:raze each m,''".-"m in\:where 0 1 in/:.d10.nm
q)m1
"...F---------7.F-7.F-7.F-7.F---7........."
"...|.F-----7.|.|.|.|.|.|.|.|.F-J........."
"...|.|...F-J.|.|.|.|.|.|.|.|.L-7........."
".F-J.L-7.L-7.L-J.L-J.|.|.L-J...L---7....."
".L-----J...L-7.......L-J.S.7.F---7.L-7..."
".........F---J.....F-7.F-J.|.L-7.L-7.L-7."
".........L-7...F-7.|.|.L-7.|...L-7.L-7.|."
"...........|.F-J.L-J.|.F-J.|.F-7.|...L-J."
".........F-J.L---7...|.|...|.|.|.|......."
".........L-------J...L-J...L-J.L-J......."
```
We do a similar operation vertically:
```q
q)m2:enlist[count[m1 0]#"."],raze m1(;)'".|"m1 in\:where 1 0 in/:.d10.nm
q)m2
"........................................."
"...F---------7.F-7.F-7.F-7.F---7........."
"...|.........|.|.|.|.|.|.|.|...|........."
"...|.F-----7.|.|.|.|.|.|.|.|.F-J........."
"...|.|.....|.|.|.|.|.|.|.|.|.|..........."
"...|.|...F-J.|.|.|.|.|.|.|.|.L-7........."
"...|.|...|...|.|.|.|.|.|.|.|...|........."
".F-J.L-7.L-7.L-J.L-J.|.|.L-J...L---7....."
".|.....|...|.........|.|...........|....."
".L-----J...L-7.......L-J.S.7.F---7.L-7..."
".............|.............|.|...|...|..."
".........F---J.....F-7.F-J.|.L-7.L-7.L-7."
".........|.........|.|.|...|...|...|...|."
".........L-7...F-7.|.|.L-7.|...L-7.L-7.|."
"...........|...|.|.|.|...|.|.....|...|.|."
"...........|.F-J.L-J.|.F-J.|.F-7.|...L-J."
"...........|.|.......|.|...|.|.|.|......."
".........F-J.L---7...|.|...|.|.|.|......."
".........|.......|...|.|...|.|.|.|......."
".........L-------J...L-J...L-J.L-J......."
"........................................."
```
The flood fill is another BFS. We start with the queue containing all the edge positions:
```q
queue:raze(til[count m2],\:/:0,count[m2 0]-1),(0,count[m2]-1),/:\:1+til[count[m2 0]-2]
```
During each iteration, we mark the map at the positions currently in the queue:
```q
m2:.[;;:;"o"]/[m2;queue]
```
We generate the lists of next nodes - this time in all 8 directions:
```q
nxts:distinct raze queue+/:\:-1_raze -1 1 0,/:\:-1 1 0
```
We discard any positions that would go off the map:
```q
nxts:nxts where all each nxts within\:(0 0;(count[m2]-1;count[m2 0]-1))
```
We also only keep the positions that correspond to empty tiles in the map (this also filters out visited positions as we already marked them on the map by changing their tile to `"o"`):
```q
nxts:nxts where "."=m2 ./:nxts
```
We update the queue to the new set of next nodes:
```q
queue:nxts
```
After the fill, the map will look like this:
```q
q)m2
"ooooooooooooooooooooooooooooooooooooooooo"
"oooF---------7oF-7oF-7oF-7oF---7ooooooooo"
"ooo|.........|o|.|o|.|o|.|o|...|ooooooooo"
"ooo|.F-----7.|o|.|o|.|o|.|o|.F-Jooooooooo"
"ooo|.|ooooo|.|o|.|o|.|o|.|o|.|ooooooooooo"
"ooo|.|oooF-J.|o|.|o|.|o|.|o|.L-7ooooooooo"
"ooo|.|ooo|...|o|.|o|.|o|.|o|...|ooooooooo"
"oF-J.L-7oL-7.L-J.L-J.|o|.L-J...L---7ooooo"
"o|.....|ooo|.........|o|...........|ooooo"
"oL-----JoooL-7.......L-J.F-7.F---7.L-7ooo"
"ooooooooooooo|...........|o|.|ooo|...|ooo"
"oooooooooF---J.....F-7.F-Jo|.L-7oL-7.L-7o"
"ooooooooo|.........|o|.|ooo|...|ooo|...|o"
"oooooooooL-7...F-7.|o|.L-7o|...L-7oL-7.|o"
"ooooooooooo|...|o|.|o|...|o|.....|ooo|.|o"
"ooooooooooo|.F-JoL-Jo|.F-Jo|.F-7.|oooL-Jo"
"ooooooooooo|.|ooooooo|.|ooo|.|o|.|ooooooo"
"oooooooooF-J.L---7ooo|.|ooo|.|o|.|ooooooo"
"ooooooooo|.......|ooo|.|ooo|.|o|.|ooooooo"
"oooooooooL-------JoooL-JoooL-JoL-Jooooooo"
"ooooooooooooooooooooooooooooooooooooooooo"
```
We need to shrink back the map to normal size, which can be done by dropping the first element, cutting by 2 and only keeping the first elements, both horizontally and vertically:
```q
q)m3:first each/:2 cut/:1_/:first each 2 cut 1_m2
q)m3
"oF----7F7F7F7F-7oooo"
"o|F--7||||||||FJoooo"
"o||oFJ||||||||L7oooo"
"FJL7L7LJLJ||LJ.L-7oo"
"L--JoL7...LJF7F-7L7o"
"ooooF-J..F7FJ|L7L7L7"
"ooooL7.F7||L7|.L7L7|"
"ooooo|FJLJ|FJ|F7|oLJ"
"ooooFJL-7o||o||||ooo"
"ooooL---JoLJoLJLJooo"
```
The answer is the number of `"."` tiles remaining in this map:
```q
q)"."=m3
00000000000000000000b
00000000000000000000b
00000000000000000000b
00000000000000100000b
00000001110000000000b
00000001100000000000b
00000010000000100000b
00000000000000000000b
00000000000000000000b
00000000000000000000b
q)sum sum"."=m3
8i
```

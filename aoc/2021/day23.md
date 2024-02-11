# Breakdown
Example input:
```q
x:"\n"vs"#############\n#...........#\n###B#C#B#D###\n  #A#D#C#A#\n  #########"
part:1
```

## Common
The solution is based on Dijkstra's algorithm.

We extract the room states by indexing, adding the extra two lines for part 2:
```q
q)rooms:enlist[x[2;3 5 7 9]],$[part=2;("DCBA";"DBAC");()],enlist x[3;3 5 7 9]
q)rooms
"BCBD"
"ADCA"
```
We cache the room size depending on the part:
```q
q)roomSize:$[part=2;4;2]
```
We create the initial node, which will contain 11 spaces for the corridor and then the rooms
transposed:
```q
q)b:enlist[11#" "],flip rooms
q)b
"           "
"BA"
"CD"
"BC"
"DA"
```
We also create a goal node, where the rooms contain the required number of A/B/C/D's:
```q
q)goal:enlist[11#" "],flip roomSize#enlist"ABCD"
q)goal
"           "
"AA"
"BB"
"CC"
"DD"
```
We initialize the queue, with the starting node having a distance of 0:
```q
q)queue:([]node:enlist[b];len:enlist 0)
q)queue
node                              len
-------------------------------------
"           " "BA" "CD" "BC" "DA" 0
```
The next part is the main iteration. We keep iterating as long as there are items in the queue. If
the queue is empty, that means we haven't reached the goal node, which is a bug, so we throw an
error.
```q
    while[0<count queue;
        ...
    ];
    '"no solution"};
```
In the iteration, we first select the node(s) to expand, which will be the nodes with the shortest
distance from the start.
```q
    nxts:select from queue where len=min len;
```
If the goal node is in the selected nodes, we are done so we can return its distance (actually we
are returning the distance of the first selected node but all of them have the same distance).
```q
    if[goal in nxts`node; :first nxts`len];
```
We delete the selected nodes from the queue:
```q
    queue:delete from queue where len=min len;
```
We expand the selected nodes (see further below):
```q
    nxts2:raze .d23.expand[roomSize] each nxts;
```
We update the queue by taking the shortest distance for each node (in case there are duplicates):
```q
    queue:0!select min len by node from queue,nxts2;
```
This is the end of the iteration.

### Node expansion
Example on the initial node:
```q
q)roomSize
2
q)row
node| ("           ";"BA";"CD";"BC";"DA")
len | 0
```
We extract the `node` field for easier access:
```q
q)node:row`node
q)node
"           "
"BA"
"CD"
"BC"
"DA"
```
We find the positions with amphipods waiting in the corridor (there are none in this example):
```q
q)waitPos:where node[0]<>" "
q)waitPos
`long$()
```
We extract the rooms part of the node for easier access:
```q
q)rooms:1_node
q)rooms
"BA"
"CD"
"BC"
"DA"
```
We find which rooms can be moved out from. This requires the room to not have only the amphipods of
the goal type, as well as not being empty:
```q
q)canMoveOut:(not all each rooms="ABCD") and 0<count each rooms
q)canMoveOut
1111b
q)moveOutInd:where canMoveOut
q)moveOutInd
0 1 2 3
```
The next section only applies if there are rooms to move out from:
```q
    if[0<count moveOutInd;
        ...
    ];
```
We find the horizontal positions of the rooms:
```q
q)moveOutPos:2+2*moveOutInd
q)moveOutPos
2 4 6 8
```
We find the letters of the top amphipod in the rooms (due to the way they were flipped, the topmost
one is first):
```q
q)moveOutLetter:first each rooms moveOutInd
q)moveOutLetter
"BCBD"
```
We convert the letters to ID numbers:
```q
q)moveOutId:"ABCD"?moveOutLetter
q)moveOutId
1 2 1 3
```
We find how many spaces they need to move vertically (since we don't store the empty spaces in the
rooms, we need to calculate these from the room occupancy counts):
```q
q)moveOutRow:1+(roomSize-count each rooms)moveOutInd
q)moveOutRow
1 1 1 1
```
We find how far amphipods may go left in the corridor. To do this we start with the corridor state,
take the prefix for each room position, then use `fills` to copy the amphipod letters into the empty
spaces. Note that `fills` only fills forward, so if we want to look left, we need to reverse the
list, and then reverse again (or rather use the correct calculations on the positions) after
filling. We find all the indices of the corridor positions that remained empty after the fill.
```q
q)gol:((moveOutPos-1)-where each" "=fills each reverse each moveOutPos#\:node 0)except\:2 4 6 8
q)gol
1 0
3 1 0
5 3 1 0
7 5 3 1 0
```
We do the same for moving right, this time there is no need to reverse.
```q
q)gor:(moveOutPos+1+where each" "=fills each (moveOutPos+1)_\:node 0)except\:2 4 6 8
q)gor
3 5 7 9 10
5 7 9 10
7 9 10
9 10
```
We calculate the costs for each movement to the left/right, using a global constant for the costs
per amphipod type:
```q
q).d23.cost
1 10 100 1000
q)golc:(moveOutRow+moveOutPos-gol)*.d23.cost moveOutId
q)golc
20 30
200 400 500
20 40 60 70
2000 4000 6000 8000 9000
q)gorc:(moveOutRow+gor-moveOutPos)*.d23.cost moveOutId
q)gorc
20 40 60 80 90
200 400 600 700
20 40 50
2000 3000
```
We generate new nodes by dropping the first element for every room we can move out of:
```q
q)nodes:@[node;;1_]each 1+moveOutInd
q)nodes
"           " ,"A" "CD" "BC" "DA"
"           " "BA" ,"D" "BC" "DA"
"           " "BA" "CD" ,"C" "DA"
"           " "BA" "CD" "BC" ,"A"
```
We further split the nodes by putting the moved-out amphipods in every possible position in the
corridor as calculated above:
```q
q)nodes2
" B         " ,"A" "CD" "BC" "DA"
"B          " ,"A" "CD" "BC" "DA"
"   B       " ,"A" "CD" "BC" "DA"
"     B     " ,"A" "CD" "BC" "DA"
"       B   " ,"A" "CD" "BC" "DA"
"         B " ,"A" "CD" "BC" "DA"
"          B" ,"A" "CD" "BC" "DA"
"   C       " "BA" ,"D" "BC" "DA"
" C         " "BA" ,"D" "BC" "DA"
"C          " "BA" ,"D" "BC" "DA"
"     C     " "BA" ,"D" "BC" "DA"
"       C   " "BA" ,"D" "BC" "DA"
"         C " "BA" ,"D" "BC" "DA"
"          C" "BA" ,"D" "BC" "DA"
..
```
We generate the final nodes by filling in the costs:
```q
q)moveOut
node                              len
--------------------------------------
" B         " ,"A" "CD" "BC" "DA" 20
"B          " ,"A" "CD" "BC" "DA" 30
"   B       " ,"A" "CD" "BC" "DA" 20
"     B     " ,"A" "CD" "BC" "DA" 40
"       B   " ,"A" "CD" "BC" "DA" 60
"         B " ,"A" "CD" "BC" "DA" 80
"          B" ,"A" "CD" "BC" "DA" 90
"   C       " "BA" ,"D" "BC" "DA" 200
" C         " "BA" ,"D" "BC" "DA" 400
"C          " "BA" ,"D" "BC" "DA" 500
"     C     " "BA" ,"D" "BC" "DA" 200
"       C   " "BA" ,"D" "BC" "DA" 400
"         C " "BA" ,"D" "BC" "DA" 600
"          C" "BA" ,"D" "BC" "DA" 700
..
```
For the second part we will use a different starting node:
```q
q)row:`node`len!(("AB   C B D ";enlist"A";enlist"D";enlist"C";"");2250)
q)node:row`node
q)waitPos:where node[0]<>" "
q)rooms:1_node
q)waitPos
0 1 5 7 9
```
Since we have positions with waiting amphipods, we check if they can move in to their final room.

We find out the letters of the waiting amphipods:
```q
q)waitLetter:node[0;waitPos]
q)waitLetter
"ABCBD"
```
We convert these to numeric IDs:
```q
q)waitId:"ABCD"?waitLetter
q)waitId
0 1 2 1 3
```
We check which rooms can be entered (all amphipods are of the type that needs to go into that room):
```q
q)openRoom:where all each rooms="ABCD"
q)openRoom
0 2 3
```
We find which waiting amphipods can go into their target rooms:
```q
q)canMoveInInd:where waitId in openRoom
q)canMoveInInd
0 2 4
```
We fetch their positions and IDs:
```q
q)canMoveInPos:waitPos canMoveInInd
q)canMoveInPos
0 5 9
q)canMoveInId:waitId canMoveInInd
q)canMoveInId
0 2 3
```
We find which row each would end up in:
```q
q)canMoveInRow:(roomSize-count each rooms) canMoveInId
q)canMoveInRow
1 1 2
```
We find the horizontal difference between their current and target positions:
```q
q)moveInDelta:(2*1+canMoveInId)-canMoveInPos
q)moveInDelta
2 1 -1
```
We check which positions they have to move through to get to their destionations:
```q
q)moveInPath:canMoveInPos+signum[moveInDelta]*1+til each abs moveInDelta
q)moveInPath
1 2
,6
,8
```
We find which amphipods have a clear path to their destination:
```q
q)moveInPath inter\:waitPos
,1
`long$()
`long$()
q)pathClearInd:where 0=count each moveInPath inter\:waitPos
q)pathClearInd
1 2
```
We filter the position/row lists to this new list of candidates:
```q
q)canMoveInPos2:canMoveInPos pathClearInd
q)canMoveInPos2
5 9
q)canMoveInRow2:canMoveInRow pathClearInd
q)canMoveInRow2
1 2
q)canMoveInId2:canMoveInId pathClearInd
q)canMoveInId2
2 3
```
We generate new nodes by removing one of the waiting amphipods from the corridor for each node:
```q
q)nodes:{[node;pos].[node;(0;pos);:;" "]}[node]each canMoveInPos2
q)nodes
"AB     B D " ,"A" ,"D" ,"C" ""
"AB   C B   " ,"A" ,"D" ,"C" ""
```
We update the nodes by putting the moved amphipod in its respective room:
```q
q)nodes2:{[node;id]@[node;1+id;("ABCD"id),]}'[nodes;canMoveInId2]
q)nodes2
"AB     B D " ,"A" ,"D" "CC" ""
"AB   C B   " ,"A" ,"D" ,"C" ,"D"
```
We calculate the distances by adding the cost of moving both horizontally and vertically:
```q
q)moveIn:([]node:nodes2;len:row[`len]+(abs[canMoveInPos2-2+2*canMoveInId2]+canMoveInRow2)*.d23.cost canMoveInId2)
q)moveIn
node                              len
--------------------------------------
"AB     B D " ,"A" ,"D" "CC" ""   2450
"AB   C B   " ,"A" ,"D" ,"C" ,"D" 5250
```
After these two steps, the `moveOut` and `moveIn` variables together will contain the list of
expanded nodes:
```q
    moveOut,moveIn
```

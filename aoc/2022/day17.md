# Breakdown
Example input:
```q
x:"\n"vs">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>";
```

## Common
We hardcode the rock shapes and their sizes:
```q
.d17.shape:{raze til[count x],/:'where each x}each not null
    (enlist"####";(" # ";"###";" # ");("  #";"  #";"###");
    enlist each"####";("##";"##"));
.d17.ssz:1+max each .d17.shape;
```
We transform the directions into -1/1 instead of the arrows:
```q
dir:-1+2*">"=first x;
```
We initialize a couple of variables: a cache of the direcion count; the field (which starts empty); the direction index `i`; the number of pieces dropped; the top of the current piece (starting from 0 when the piece is dropped):
```q
dc:count dir;
field:();
i:-1;
pcs:0;
top:0N;
```
Furthermore we keep a field log which stores what the top of the field looked like when we dropped each piece:
```q
flog:enlist[()]!enlist `int$();
```
And we also keep the log of the field height on every piece drop:
```q
hlog:`int$();
```
The main loop will run without a terminating condition, there will be a return in the middle:
```q
while[1b;
```
We pull the next direction:
```q
i+:1;
d:dir[i mod dc];
```
We drop a piece if necessary - we indicate this by having null in the `top` variable:
```q
if[null top;
```
We drop any empty lines from the top of the field:
```q
m:0; while[$[m=count field;0b;0=sum field m]; m+:1];
field:m _field;
```
If we exceeded the piece limit (we only will for part 1), we return the current field height:
```q
if[pcs>=lim; :count[field]];
```
Otherwise, we log the field snapshot (the first 12 lines) and the height:
```q
hlog,:count field;
snap:0b,raze 12 sublist field;
flog[snap],:pcs;
```
The terminating condition for part 2 is when we find a cycle in the snapshot pattern. So first we check if the current snapshot has 3 indices already:
```q
if[3<=count st:flog[snap];
```
We also check if the differences between the elements is the same, which indicates that indeed we found a cycle:
```q
if[1=count pers:distinct 1_deltas st;
```
We then calculate the total height as indicated by the comments below:
```q
per:first pers;
hfst:hlog[st 0];    //height in first partial period
hper:hlog[st 2]-hlog[st 1]; //height per period
fullPers:(lim-st 0)div per; //number of full periods
plst:(lim-st 0)mod per;  //pieces in last partial period
hlst:hlog[plst+st 1]-hlog[st 1]; //height in last partial period
:hfst+(fullPers*hper)+hlst;
```
If we haven't found a cycle, we go ahead and fetch the next piece to drop:
```
];
];
shape:.d17.shape pcs mod 5;
ssz:.d17.ssz pcs mod 5;
```
We expand the field on top to make room for the piece, initialize the top/left coordinates of the piece and add one to the piece counter:
```q
field:((ssz[0]+3)#enlist 7#0b),field;
top:0;
left:2;
pcs+:1;
```
After dropping a piece if necessary, we can move on to actually moving the piece. First we update the left coordinate:
```q
];
left+:d;
```
If this move would cause the piece to go out of bounds, we push the piece inwards:
```q
if[7<left+ssz 1; left-:1];
if[0>left; left+:1];
```
If the piece would overlap an already existing piece, we reverse the move:
```q
if[any field ./:(top;left)+/:shape; left-:d];
```
Next we increase the top coordinate, and initialize such that we haven't encountered a hit:
```q
top+:1;
hit:0b;
```
If we hit the bottom of the field, we register a hit:
```
if[count[field]<top+ssz 0; hit:1b];
```
If we overlap with a previous piece, we also register a hit:
```q
if[any field ./:(top;left)+/:shape; hit:1b];
```
If we registered a hit, we undo the vertical move:
```q
if[hit;
top-:1;
```
We also "imprint" the piece in the field and set the top to null to indicate that a new piece needs to be dropped.
```q
field:.[;;:;1b]/[field;(top;left)+/:shape];
top:0N;
```
This is the end of the main loop.

The same solution works for part 1 and part 2, it will exit when either the given piece limit expires or we find a cycle in the pattern in the top of the field which allows us to calculate the final height. Note that for the top 12 rows, we don't take into account which piece and movement is coming next, also pieces may fall more than 12 lines, but still this proved to be a good enough heuristic.

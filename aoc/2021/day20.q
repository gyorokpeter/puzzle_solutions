d20:{[times;x]
    a:"\n\n"vs x;
    prog:"#"=a[0]except"\n";
    map:"#"="\n"vs a 1;
    step:0;
    do[times;
        edge:$[prog 0;`boolean$step mod 2;0b];
        map1:{[edge;x]row:count[x 0]#edge;enlist[row],x,enlist[row]}[edge;edge,/:map,\:edge];
        maps:raze -1 0 1 rotate/:\:-1 0 1 rotate/:\:map1;
        map:prog 2 sv/:/:flip each flip maps;
        step+:1;
    ];
    sum sum map};
d20p1:{d20[2;x]};
d20p2:{d20[50;x]};

/
OVERVIEW:

This is a simulation of a cellular automaton that is very similar to day 11. This time the
rotations are kept in order as we do need the 0,0 rotation, and also need the contents of each
cell in the correct order. After doing the rotations, we do "flip each flip maps" to make sure that
the last dimension is the rotation number. Initially the dimensions are "rotation,y,x" and a single
flip swaps the two topmost coordinates, but we can use "each" to push it down one level. So a
single flip turns it into "y,rotation,x", and a flip each after that turns it into "y,x,rotation".
Then we use the familiar 2 sv to turn the binary numbers into decimal which can be used as an
index.
There is a nasty trick in this puzzle in that the infinite grid is supposed to obey the rules as
well, not just the part that has the nonempty cells. This is only significant if the very first
element of the enhancement array is "on", in which case all of the cells in the initially empty
infinite space turn on. However this will only result in a finite answer if the last element of the
array is "off", which will make the outer cells flicker between on and off on every step. The way
this affects the algorithm is that if the zero instruction is "on", we don't just pad the grid with
zeros, but with either ones or zeros depending on the current step.

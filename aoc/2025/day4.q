d4:{[a]f:00b a 0;
    r:(0b,/:-1_/:a;(1_/:a),\:0b;enlist[f],-1_a;(1_a),enlist[f]);
    r,:(0b,/:-1_/:r 2;(1_/:r 2),\:0b;0b,/:-1_/:r 3;(1_/:r 3),\:0b);
    (4>sum r)and a};
d4p1:{a:x="@";sum sum d4 a};
d4p2:{a:x="@";
    a2:{x and not d4 x}/[a];
    sum sum a and not a2};

/
x:();
x,:enlist"..@@.@@@@.";
x,:enlist"@@@.@.@.@@";
x,:enlist"@@@@@.@.@@";
x,:enlist"@.@@@@..@.";
x,:enlist"@@.@@@@.@@";
x,:enlist".@@@@@@@.@";
x,:enlist".@.@.@.@@@";
x,:enlist"@.@@@.@@@@";
x,:enlist".@@@@@@@@.";
x,:enlist"@.@.@@@.@.";

d4p1 x  //13
d4p2 x  //43

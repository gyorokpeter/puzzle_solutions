d7p1:{a:(where each x in"S^")except enlist`long$();
    a2:{[(n;b1);b2]
        s:b1 inter b2;
        (n+count s;distinct(b1 except s),raze s+/:1 -1)}/[(0;a 0);1_a];
    first a2};
d7p2:{a:(where each x in"S^")except enlist`long$();
    a2:{s:key[x]inter y;
        sum(s _x;(s+1)!x s;(s-1)!x s)}/[a[0]!count[a 0]#1;1_a];
    sum a2};

/
x:();
x,:enlist".......S.......";
x,:enlist"...............";
x,:enlist".......^.......";
x,:enlist"...............";
x,:enlist"......^.^......";
x,:enlist"...............";
x,:enlist".....^.^.^.....";
x,:enlist"...............";
x,:enlist"....^.^...^....";
x,:enlist"...............";
x,:enlist"...^.^...^.^...";
x,:enlist"...............";
x,:enlist"..^...^.....^..";
x,:enlist"...............";
x,:enlist".^.^.^.^.^...^.";
x,:enlist"...............";

d7p1 x  //21
d7p2 x  //40

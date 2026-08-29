d1p1:{n:"J"$","vs/:x;
    sum last each{d:last[x]-y;if[(d in x)or d<0;d:last[x]+y];x,d}/[enlist 0;]each n};
d1p2:{n:"J"$","vs/:x;
    sum last each{d:last[x]-y;if[(d in x)or d<0;d:last[x]+y;while[d in x;d+:1]];x,d}/[enlist 0;]each n};
d1p3:{n:"J"$","vs/:x;
    f:{[l;s]
        a:last l;
        arc:asc each 2 cut (1-count[l]mod 2)_-1_l;
        aw:a within/:arc;
        lim:$[sum 0b,aw;max last each arc where aw;0W];
        d:a-s;
        if[any(d in l;d<0;not aw~d within/:arc);
            d:a+s;
            while[(d<lim)and(d in l) or not aw~d within/:arc;d+:1];
            if[d>=lim;:l];
        ];
        l,:d;
        l};
    sum last each f/[enlist 0;]each n};

/
x:();
x,:enlist"1,2,3,4,5,6,7,8,9";
x,:enlist"1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30";

x2:();
x2,:enlist"1,1,1,1,1";
x2,:enlist"5,1,2,3,4,5,1,2,3,4";
x2,:enlist"2,1,1,2,1,1,2,1,1,2,1,1";
x2,:enlist"5,1,2,1,2,7,1,2,1,2,7,1,2,1,2";

x3:();
x3,:enlist"5,3,1,1";
x3,:enlist"5,3,1,1,5,1,1,3,4,8,1,1";
x3,:enlist"5,3,1,1,5,1,1,3,4,8,2,1";
x3,:enlist"10,9,9,8,8,7,7,6,6,5,5,4,4,3,3,2,2,1";

d1p1 x  //66
d1p1 x2 //34
d1p2 x2 //34
d1p3 x2 //27
d1p3 x3 //35

d1p1 read0`:everybody_codes_e4_q01_p1.txt
d1p2 read0`:everybody_codes_e4_q01_p2.txt
d1p3 read0`:everybody_codes_e4_q01_p3.txt

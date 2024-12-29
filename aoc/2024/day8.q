d8:{[f;x]h:count x; w:count x 0;
    a:" ."_(,')/[(enlist[" "]!enlist()),/:til[h],/:/:'group each x];
    b:{[f;x]x{[f;x;y]$[x~y;();f[x;y]]}[f]/:\:x}[f]each a;
    c:raze raze raze b;
    count distinct c where all each c within\:(0 0;(h-1;w-1))};
d8p1:{d8[{enlist y+y-x};x]};
d8p2:{h:count x; w:count x 0;
    f:{[h;w;x;y]((y-x)+)\['[all;within[;(0 0;(h-1;w-1))]];y]}[h;w];
    d8[f;x]};

/

x:();
x,:enlist"............";
x,:enlist"........0...";
x,:enlist".....0......";
x,:enlist".......0....";
x,:enlist"....0.......";
x,:enlist"......A.....";
x,:enlist"............";
x,:enlist"............";
x,:enlist"........A...";
x,:enlist".........A..";
x,:enlist"............";
x,:enlist"............";

d8p1 x  //14
d8p2 x  //34

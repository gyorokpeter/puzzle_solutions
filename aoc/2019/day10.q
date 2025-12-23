//gcd:{$[x<0;.z.s[neg x;y];x=y;x;x>y;.z.s[y;x];x=0;y;.z.s[x;y mod x]]};
gcdv:{exec y from {[xy]
    xy:update x:min(x;y),y:max(x;y) from xy;
    xy:update y:y mod x from xy where 0<x;
    xy}/[([]abs x;abs y)]};
pi:2*acos 0;
atan2:{[y;x]$[x>0;atan[y%x];(x<0)and y>=0; atan[y%x]+pi;(x<0)and y<0;atan[y%x]-pi;(x=0)and y>0;pi%2;(x=0)and y<0;neg pi%2;0n]};
vlen:{sqrt(x*x)+y*y};

d10:{a:"#"=x;
    b:raze(where each a),\:'til count a;
    c:(b-\:/:b)except\:enlist 0 0;
    d:distinct each c div gcdv ./:flip each c;
    (b;c;d)};
d10p1:{bcd:d10[x];
    max count each bcd[2]};
d10p2:{bcd:d10[x];b:bcd[0];c:bcd[1];d:bcd[2];
    e:first {where x=max x}count each d;
    f:b e;
    g:update x:dx+f[0], y:dy+f[1] from flip`dx`dy!flip c e;
    h:`a`r xasc update r:vlen[dx;dy], a:(atan2'[dy;dx]+pi%2)mod 2*pi from g;
    j:update ri:til each count each r from select dx, dy, x, y, r by a from h;
    k:`ri`a xasc ungroup j;
    sum 100 1*k[199][`x`y]};

/
x:"\n"vs"......#.#.\n#..#.#....\n..#######.\n.#.#.###..\n.#..#.....\n..#....#.#\n#..#....#.";
x,:"\n"vs".##.#..###\n##...#..#.\n.#....####";

x2:"\n"vs"#.#...#.#.\n.###....#.\n.#....#...\n##.#.#.#.#\n....#.#.#.\n.##..###.#\n..#...##..";
x2,:"\n"vs"..##....##\n......#...\n.####.###.";

x3:"\n"vs".#..#..###\n####.###.#\n....###.#.\n..###.##.#\n##.##.#.#.\n....###..#\n..#.#..#.#";
x3,:"\n"vs"\n#..#.#.###\n.##...##.#\n.....#.#..";

x4:();
x4,:enlist".#..##.###...#######";
x4,:enlist"##.############..##.";
x4,:enlist".#.######.########.#";
x4,:enlist".###.#######.####.#.";
x4,:enlist"#####.##.#.##.###.##";
x4,:enlist"..#####..#.#########";
x4,:enlist"####################";
x4,:enlist"#.####....###.#.#.##";
x4,:enlist"##.#################";
x4,:enlist"#####.##.###..####..";
x4,:enlist"..######..##.#######";
x4,:enlist"####.##.####...##..#";
x4,:enlist".#####..#.######.###";
x4,:enlist"##...#.##########...";
x4,:enlist"#.##########.#######";
x4,:enlist".####.#.###.###.#.##";
x4,:enlist"....##.##.###..#####";
x4,:enlist".#.#.###########.###";
x4,:enlist"#.#.#.#####.####.###";
x4,:enlist"###.##.####.##.#..##";

d10p1 x     //33
d10p1 x2    //35
d10p1 x3    //41
d10p1 x4    //210
//d10p1 x
d10p2 x4    //802

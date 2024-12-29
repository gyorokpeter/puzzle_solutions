d16:{start:first raze til[count x],/:'where each x="S";
    end:first raze til[count x],/:'where each x="E";
    map:.[;;:;"."]/[x;(start;end)];
    queue:([]pos:enlist start;dir:1;score:0;path:enlist enlist start);
    visited:();
    while[count queue;
        nxts:select from queue where score=min score;
        if[end in exec pos from nxts;
            good:select from nxts where pos~\:end;
            best:exec min score from good;
            tiles:distinct raze exec path from good;
            -1 .[;;:;"O"]/[map;tiles];
            :(best;count tiles);
        ];
        queue:delete from queue where score=min score;
        visited,:exec (pos,'dir) from nxts;
        nxts:raze{
            update path:(path,'enlist each pos) from ([]pos:enlist x[`pos]+(-1 0;0 1;1 0;0 -1)x`dir;
                dir:x`dir;score:1+x`score;path:enlist x`path),
            ([]pos:2#enlist x[`pos];dir:(x[`dir]+1 -1)mod 4;score:1000+x`score;path:2#enlist x`path)
        }each nxts;
        nxts:delete from nxts where (pos,'dir) in visited;
        nxts:delete from nxts where "#"=map ./:pos;
        queue:select from queue,nxts where score=(min;score)fby ([]pos;dir);
    ];
    {'x}"no solution"};
d16p1:{d16[x][0]};
d16p2:{d16[x][1]};

/

x:();
x,:enlist"###############";
x,:enlist"#.......#....E#";
x,:enlist"#.#.###.#.###.#";
x,:enlist"#.....#.#...#.#";
x,:enlist"#.###.#####.#.#";
x,:enlist"#.#.#.......#.#";
x,:enlist"#.#.#####.###.#";
x,:enlist"#...........#.#";
x,:enlist"###.#.#####.#.#";
x,:enlist"#...#.....#.#.#";
x,:enlist"#.#.#.###.#.#.#";
x,:enlist"#.....#...#.#.#";
x,:enlist"#.###.#.#.#.#.#";
x,:enlist"#S..#.....#...#";
x,:enlist"###############";

x2:();
x2,:enlist"#################";
x2,:enlist"#...#...#...#..E#";
x2,:enlist"#.#.#.#.#.#.#.#.#";
x2,:enlist"#.#.#.#...#...#.#";
x2,:enlist"#.#.#.#.###.#.#.#";
x2,:enlist"#...#.#.#.....#.#";
x2,:enlist"#.#.#.#.#.#####.#";
x2,:enlist"#.#...#.#.#.....#";
x2,:enlist"#.#.#####.#.###.#";
x2,:enlist"#.#.#.......#...#";
x2,:enlist"#.#.###.#####.###";
x2,:enlist"#.#.#...#.....#.#";
x2,:enlist"#.#.#.#####.###.#";
x2,:enlist"#.#.#.........#.#";
x2,:enlist"#.#.#.#########.#";
x2,:enlist"#S#.............#";
x2,:enlist"#################";

d16 x   //7036 45
d16 x2  //11048 64

x3:();
x3,:enlist"###";
x3,:enlist"#E#";
x3,:enlist"#S#";
x3,:enlist"#.#";
x3,:enlist"###";
d16p2 x3    //2 (no adding of path going down when it's not a good path)

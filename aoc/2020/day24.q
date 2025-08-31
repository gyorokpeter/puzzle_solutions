d24:{ins:"J"$/:/:ssr/[;("ne";"nw";"sw";"se";"e";"w");"124503"]each x;
    where 1=(count each group sum each(1 0;1 1;0 1;-1 0;-1 -1;0 -1)ins)mod 2};
d24p1:{count d24 x};
d24p2:{c:d24 x;
    st:{[c]
        nb:raze(1 0;1 1;0 1;-1 0;-1 -1;0 -1)+/:\:c;
        nbs:count each group nb;
        (c inter where nbs within 1 2) union ((where 2=nbs) except c)}/[100;c];
    count st};

/
x:();
x,:enlist"sesenwnenenewseeswwswswwnenewsewsw";
x,:enlist"neeenesenwnwwswnenewnwwsewnenwseswesw";
x,:enlist"seswneswswsenwwnwse";
x,:enlist"nwnwneseeswswnenewneswwnewseswneseene";
x,:enlist"swweswneswnenwsewnwneneseenw";
x,:enlist"eesenwseswswnenwswnwnwsewwnwsene";
x,:enlist"sewnenenenesenwsewnenwwwse";
x,:enlist"wenwwweseeeweswwwnwwe";
x,:enlist"wsweesenenewnwwnwsenewsenwwsesesenwne";
x,:enlist"neeswseenwwswnwswswnw";
x,:enlist"nenwswwsewswnenenewsenwsenwnesesenew";
x,:enlist"enewnwewneswsewnwswenweswnenwsenwsw";
x,:enlist"sweneswneswneneenwnewenewwneswswnese";
x,:enlist"swwesenesewenwneswnwwneseswwne";
x,:enlist"enesenwswwswneneswsenwnewswseenwsese";
x,:enlist"wnwnesenesenenwwnenwsewesewsesesew";
x,:enlist"nenewswnwewswnenesenwnesewesw";
x,:enlist"eneswnwswnwsenenwnwnwwseeswneewsenese";
x,:enlist"neswnwewnwnwseenwseesewsenwsweewe";
x,:enlist"wseweeenwnesenwwwswnew";

d24p1 x //10
d24p2 x //2208

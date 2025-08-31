d3:{[map;slope]"j"$sum"#"=map ./:(reverse[slope]*/:til count[map]div slope 1) mod\:(count map;count map 0)};
d3p1:{d3[x;3 1]};
d3p2:{prd d3[x]each(1 1;3 1;5 1;7 1;1 2)};

/
x: enlist"..##.......";
x,:enlist"#...#...#..";
x,:enlist".#....#..#.";
x,:enlist"..#.#...#.#";
x,:enlist".#...##..#.";
x,:enlist"..#.##.....";
x,:enlist".#.#.#....#";
x,:enlist".#........#";
x,:enlist"#.##...#...";
x,:enlist"#...##....#";
x,:enlist".#..#...#.#";

d3p1 x  //7
d3p2 x  //336

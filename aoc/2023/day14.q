.d14.west:{"#"sv/:desc each/:"#"vs/:x};
.d14.east:{"#"sv/:asc each/:"#"vs/:x};
.d14.weight:{sum sum(count[x]-til count x)*x="O"};
d14p1:{.d14.weight flip .d14.west flip x};
d14p2:{
    step:{
        x:flip .d14.west flip x;
        x:.d14.west x;
        x:flip .d14.east flip x;
        x:.d14.east x;
    x};
    a:x;seen:();while[not any b:a~/:seen;seen,:enlist a;a:step a];
    loopStart:first where b; loopLen:count[seen]-loopStart;
    .d14.weight seen loopStart+(1000000000-loopStart)mod loopLen};

/
x:();
x,:"\n"vs"O....#....\nO.OO#....#\n.....##...\nOO.#O....O\n.O.....O#.\nO.#..O.#.#";
x,:"\n"vs"..O..#O..O\n.......O..\n#....###..\n#OO..#....";

d14p1 x //136
d14p2 x //64

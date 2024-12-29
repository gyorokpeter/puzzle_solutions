d25:{a:"#"="\n"vs/:"\n\n"vs"\n"sv x;
    isKey:all each first each a;
    cnts:sum each a;
    ky:cnts where isKey;
    lk:cnts where not isKey;
    sum sum all each/:(ky+/:\:lk)<=count first a};

/
x:"\n"vs"#####\n.####\n.####\n.####\n.#.#.\n.#...\n.....\n";
x,:"\n"vs"#####\n##.##\n.#.##\n...##\n...#.\n...#.\n.....\n";
x,:"\n"vs".....\n#....\n#....\n#...#\n#.#.#\n#.###\n#####\n";
x,:"\n"vs".....\n.....\n#.#..\n###..\n###.#\n###.#\n#####\n";
x,:"\n"vs".....\n.....\n.....\n#....\n#.#..\n#.#.#\n#####";

d25 x   //3
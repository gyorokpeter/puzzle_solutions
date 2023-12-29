.d13.ind:{x!{[c]i1:{((til x);x+reverse til x)}each 1+til c div 2;
    i2:i1,reverse each reverse(c-1)-i1}each x}7 9 11 13 15 17;
.d13.findMirror:{[n]nh:2 sv/:n; nv:2 sv/:flip n;
    fl2:{[nh]ns:nh .d13.ind count nh; 1+where ns[;0]~'ns[;1]};
    fl2[nv],100*fl2[nh]};
d13p1:{a:"#"="\n"vs/:"\n\n"vs"\n"sv x;
    sum raze .d13.findMirror each a};
d13p2:{a:"#"="\n"vs/:"\n\n"vs"\n"sv x;
    f:{[n]def:.d13.findMirror n; inds:til[count[n]]cross til count first n;
        (distinct raze .d13.findMirror each .[n;;not]each inds)except def};
    sum raze f each a};

/
x:();
x,:"\n"vs"#.##..##.\n..#.##.#.\n##......#\n##......#\n..#.##.#.\n..##..##.\n#.#.##.#.\n";
x,:"\n"vs"#...##..#\n#....#..#\n..##..###\n#####.##.\n#####.##.\n..##..###\n#....#..#";

d13p1 x //405
d13p2 x //400

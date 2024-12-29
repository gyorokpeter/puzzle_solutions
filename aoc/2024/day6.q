d6p1:{w:count first x; h:count x;
    pos:first raze til[h],/:'where each"^"=x;
    a:x; a[pos 0;pos 1]:".";
    dir:0;
    visited:enlist pos;
    while[all pos within'(1,h-2;1,w-2);
        nxt:pos+(-1 0;0 1;1 0;0 -1)dir;
        $["#"=a . nxt;dir:(dir+1)mod 4;
            [pos:nxt;visited,:enlist pos]];
        ];
    count distinct visited};
d6p2:{w:count first x; h:count x;
    pos:first raze til[h],/:'where each"^"=x;
    a:x; a[pos 0;pos 1]:".";
    queue:([]enlist pos;dir:0;obstacle:enlist 0N 0N);
    visited:enlist pos;
    step:0;
    while[count queue;
        step+:1;
        queue:update nxt:pos+(-1 0;0 1;1 0;0 -1)dir from queue;
        queue:update tile:a ./:nxt from queue;
        queue:delete from queue where tile=" ";
        queue:update bump:(tile="#") or nxt~'obstacle from queue;
        queue:update dir:(dir+1)mod 4 from queue where bump;
        place:select from queue where tile=".", null first each obstacle, not nxt in visited;
        place:update dir:(dir+1)mod 4, obstacle:nxt from place;
        queue:update pos:nxt from queue where not bump;
        queue:delete nxt,tile,bump from queue,place;
        if[step>w*h;
            :count exec distinct obstacle from queue;
        ];
        visited,:exec pos from queue where null first each obstacle;
        -1"step=",string[step]," count queue=",string count queue;
    ];
    0};

/

x:();
x,:enlist"....#.....";
x,:enlist".........#";
x,:enlist"..........";
x,:enlist"..#.......";
x,:enlist".......#..";
x,:enlist"..........";
x,:enlist".#..^.....";
x,:enlist"........#.";
x,:enlist"#.........";
x,:enlist"......#...";

d6p1 x  //41
d6p2 x  //6

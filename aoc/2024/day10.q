d10:{[part;x]
    a:"J"$/:/:x;
    queue:update pos:orig from([]orig:raze til[count a],/:'where each a=0;cnt:1);
    step:0;
    while[step<9;
        step+:1;
        queue:raze queue,/:'flip each select nxt:pos+/:\:(-1 0;0 1;1 0;0 -1) from queue;
        queue:select from queue where step=a ./:nxt;
        queue:0!select sum cnt by orig,pos:nxt from queue;
    ];
    $[part=1;count queue;
        exec sum cnt from queue]};
d10p1:{d10[1;x]};
d10p2:{d10[2;x]};

/

x:();
x,:enlist"89010123";
x,:enlist"78121874";
x,:enlist"87430965";
x,:enlist"96549874";
x,:enlist"45678903";
x,:enlist"32019012";
x,:enlist"01329801";
x,:enlist"10456732";

d10p1 x //36
d10p2 x //81

d20:{[times;x]
    a:"\n\n"vs x;
    prog:"#"=a[0]except"\n";
    map:"#"="\n"vs a 1;
    step:0;
    do[times;
        edge:$[prog 0;`boolean$step mod 2;0b];
        map1:{[edge;x]row:count[x 0]#edge;enlist[row],x,enlist[row]}[edge;edge,/:map,\:edge];
        maps:raze -1 0 1 rotate/:\:-1 0 1 rotate/:\:map1;
        map:prog 2 sv/:/:flip each flip maps;
        step+:1;
    ];
    sum sum map};
d20p1:{d20[2;x]};
d20p2:{d20[50;x]};

d9:{a:"J"$/:/:"\n"vs x;
    w:count first a;
    g:all a</:((1_/:a),\:0W;0W,/:-1_/:a;1_a,enlist w#0W;enlist[w#0W],-1_a);
    (a;w;g)};
d9p1:{r:d9[x]; sum sum r[2]+r[0]*r[2]};
d9p2:{
    r:d9[x];a:r[0];w:r[1];g:r[2];h:count a;
    nodes:update basin:1+i from ([]pos:raze til[count a],/:'where each g);
    queue:nodes;
    visited:nodes;
    while[0<count queue;
        nxts:distinct ungroup update pos:pos+/:\:(-1 0;0 -1;1 0;0 1) from queue;
        nxts:select from nxts where pos[;0] within (0;h-1), pos[;1] within (0;w-1);
        nxts:select from nxts where not pos in (exec pos from visited), 9>a ./:pos;
        visited,:nxts;
        queue:nxts;
    ];
    prd 3#desc exec count i by basin from visited};

/
d9p1 x:"2199943210\n3987894921\n9856789892\n8767896789\n9899965678"
d9p2 x

.d25.topNodes:{[conn2;start]
    queue:enlist start;
    parent:key[conn2]!count[conn2]#`;
    parent[first queue]:`000;
    while[count queue;
        nxts:raze queue,/:'conn2 queue;
        nxts:nxts where null parent nxts[;1];
        parent[nxts[;1]]:nxts[;0];
        queue:distinct nxts[;1];
    ];
    if[any null parent; :(0b;value group null parent)];
    paths:-2_/:(parent\)each key conn2;
    freq:desc count each group raze paths;
    (1b;10#freq)};
d25:{p:": "vs/:x;
    conn:(`$p[;0])!`$" "vs/:p[;1];
    e:{distinct x,reverse each x}raze(`$p[;0]),/:'`$" "vs/:p[;1];
    conn2:exec t by s from flip`s`t!flip e;
    curr:first key conn2;
    seen:();
    while[1b;
        seen,:curr;
        nxt:.d25.topNodes[conn2;curr];
        if[not first nxt;
            :prd count each nxt 1;
        ];
        curr:key[nxt[1]][1];
        if[curr in seen;
            bridge:-2#seen;
            -1"found bridge: ",.Q.s1 bridge;
            conn2[bridge 0]:conn2[bridge 0] except bridge 1;
            conn2[bridge 1]:conn2[bridge 1] except bridge 0;
            seen:();
        ];
    ];
    };

/
x:"\n"vs"jqt: rhn xhk nvd\nrsh: frs pzl lsr\nxhk: hfx\ncmg: qnr nvd lhk bvb\nrhn: xhk bvb hfx";
x,:"\n"vs"bvb: xhk hfx\npzl: lsr hfx nvd\nqnr: nvd\nntq: jqt hfx bvb xhk\nnvd: lhk\nlsr: lhk";
x,:"\n"vs"rzs: qnr cmg lsr rsh\nfrs: qnr lhk lsr";

d25 x //54

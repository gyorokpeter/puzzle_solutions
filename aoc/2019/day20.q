d20:{
    label:([]lb:`$();ci:`long$();cj:`long$();dk:`long$());
    ll:x within "AZ";
    lld:ll and (-1_enlist[count[first x]#0b],ll) and ((-2_(2#enlist(count first x)#" "),x)=".");
    lbd:raze til[count lld],/:'where each lld;
    label,:([]lb:`$x ./:/:(-1 0;0 0)+\:/:lbd;ci:lbd[;0]-2;cj:lbd[;1];dk:?[lbd[;0]<count[x]div 2;-1;1]);
    llu:ll and ((1_ll),enlist[count[first x]#0b]) and (((2_x),2#enlist(count first x)#" ")=".");
    lbu:raze til[count lld],/:'where each llu;
    label,:([]lb:`$x ./:/:(0 0;1 0)+\:/:lbu;ci:lbu[;0]+2;cj:lbu[;1];dk:?[lbu[;0]<count[x] div 2;1;-1]);
    lll:ll and (0b,/:-1_/:ll) and "."=("  ",/:-2_/:x);
    lbl:raze til[count lll],/:'where each lll;
    label,:([]lb:`$x ./:/:(0 -1;0 0)+\:/:lbl;ci:lbl[;0];cj:lbl[;1]-2;dk:?[lbl[;1]<count[first x]div 2;-1;1]);
    llr:ll and ((1_/:ll),\:0b) and "."=((2_/:x),\:"  ");
    lbr:raze til[count llr],/:'where each llr;
    label,:([]lb:`$x ./:/:(0 0;0 1)+\:/:lbr;ci:lbr[;0];cj:lbr[;1]+2;dk:?[lbr[;1]<count[first x]div 2;1;-1]);
    label};

d20p1:{
    label:d20 x;
    start:exec (first ci;first cj) from label where lb=`AA;
    finish:exec (first ci;first cj) from label where lb=`ZZ;
    warp:raze exec {x!x except/:enlist each x}each cs from select cs:flip(ci;cj) by lb from label;
    parent:enlist[start]!enlist 0N 0N;
    queue:enlist start;
    while[count queue;
        nxts:(queue+/:\:(-1 0;0 1;1 0;0 -1)),'warp queue;
        nxtt:x ./:/:nxts;
        nxts:(nxts@'where each "."=nxtt)except\:value parent;
        parent[raze nxts]:raze (count each nxts)#'enlist each queue;
        queue:raze nxts;
        if[0<count arrive:where finish~/:queue;
            :count 1_-2_parent\[first queue arrive]
        ];
    ];
    "not found"};

d20p2:{
    label:d20 x;
    paths:([]sl:();tl:();plen:`long$());
    queue:select ls:(lb,'dk),pos:(ci,'cj) from label;
    parent:exec (ls,'pos)!count[i]#enlist 0N 0N from queue;
    while[0<count queue;
        nxts:update npos:pos+/:\:(-1 0;0 1;1 0;0 -1) from queue;
        nxts2:raze{([]ls:count[x`npos]#enlist x`ls;pos:count[x`npos]#enlist x`pos;npos:x`npos)}each nxts;
        nxts2:update ntile:x ./:npos from nxts2;
        nxts2:select from nxts2 where ntile=".", not (ls,'npos) in key parent;
        parent[exec (ls,'npos) from nxts2]:exec pos from nxts2;
        if[0<count found:select from nxts2 where npos in exec (ci,'cj) from label; 
            paths,:select sl:ls, tl: (exec ((ci,'cj)!(lb,'dk))from label)npos, plen:count each 1_/:-2_/:{[parent;x](2#x),parent[x]}[parent]\'[ls,'npos] from found;
        ];
        queue:select ls,pos:npos from nxts2;
    ];

    visited:();
    queue:([]lb:enlist`AA;k:1;d:0;plen:0);
    while[count queue;
        minl:exec min plen from queue;
        toExpand:select from queue where plen=minl;
        if[0<count found:select from toExpand where lb=`ZZ,d=0;
            :minl;
        ];
        visited,:exec (lb,'k,'d) from toExpand;
        nxts:update npos:{[paths;x](exec (tl,'x[2],/:plen) from paths where sl~\:2#x),
            $[(x[2]>0) and (x[1]=1) and x[0]<>`ZZ;enlist(x[0];-1;x[2]-1;1);()],$[x[1]=-1;enlist(x[0];1;x[2]+1;1);()]
            }[paths]each(lb,'k,'d) from toExpand;
        nxts2:ungroup nxts;
        nxts2:update plen+last each npos, -1_/:npos from nxts2;
        nxts2:select from nxts2 where not npos in visited;
        queue:(delete from queue where plen=minl),select lb:npos[;0], k:npos[;1],d:npos[;2],plen from nxts2;
        queue:0!select first plen by lb,k,d from `plen xasc queue;
    ];
    "not found"};

/
x:();
x,:enlist"         A           ";
x,:enlist"         A           ";
x,:enlist"  #######.#########  ";
x,:enlist"  #######.........#  ";
x,:enlist"  #######.#######.#  ";
x,:enlist"  #######.#######.#  ";
x,:enlist"  #######.#######.#  ";
x,:enlist"  #####  B    ###.#  ";
x,:enlist"BC...##  C    ###.#  ";
x,:enlist"  ##.##       ###.#  ";
x,:enlist"  ##...DE  F  ###.#  ";
x,:enlist"  #####    G  ###.#  ";
x,:enlist"  #########.#####.#  ";
x,:enlist"DE..#######...###.#  ";
x,:enlist"  #.#########.###.#  ";
x,:enlist"FG..#########.....#  ";
x,:enlist"  ###########.#####  ";
x,:enlist"             Z       ";
x,:enlist"             Z       ";

d20p1 x //23
d20p2 x //26

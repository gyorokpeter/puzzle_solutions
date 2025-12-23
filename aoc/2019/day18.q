d18p1:{ /solves both part 1 and 2 as long as the map is already pre-processed with the extra robots for part 2
    starts:raze til[count x],/:'where each"@"=x;
    allKeys:{asc x where x within "az"}raze x;

    queue:([]ci:starts[;0];cj:starts[;1];doors:count[starts]#enlist"");
    parent:starts!count[starts]#enlist[(0N;0N)];
    needKey:enlist[" "]!enlist"";
    while[0<count queue;
        nxts:raze{update nci:ci+-1 0 1 0,ncj:cj+0 1 0 -1 from 4#enlist x}each queue;
        nxts:update ntile:x'[nci;ncj] from nxts;
        nxts:select from nxts where not ntile="#", not (nci,'ncj) in key parent;
        nxts:update doors:asc each distinct each (doors,'lower ntile) from nxts where lower[ntile] within "az";
        parent,:exec (nci,'ncj)!(ci,'cj) from nxts;
        needKey,:exec ntile!doors except' ntile from nxts where ntile within "az";
        queue:select ci:nci, cj:ncj, doors from nxts;
    ];

    startps:starts,raze til[count x],/:'where each x within "az";
    queue:([]ci:startps[;0];cj:startps[;1]; sc:(raze string til count starts),count[starts]_x ./:startps);
    parent:(exec (;;)'[ci;cj;sc] from queue)!count[queue]#enlist[0N 0N,enlist" "];
    paths:([s:"";t:""]path:();plen:`long$());
    while[0<count queue;
        nxts:raze{update nci:ci+-1 0 1 0,ncj:cj+0 1 0 -1 from 4#enlist x}each queue;
        nxts:update ntile:x'[nci;ncj] from nxts;
        nxts:select from nxts where not ntile="#", not (;;)'[nci;ncj;sc] in key parent;
        parent,:exec (;;)'[nci;ncj;sc]!(ci,'cj) from nxts;
        pths:update path:-1_/:/:reverse each -2_/:{[p;x]p[x],-1#x}[parent]\'[(;;)'[nci;ncj;sc]] from select from nxts where ntile within "az";
        paths:paths upsert select s:sc, t:ntile, plen:count each path, path from pths;
        queue:select ci:nci, cj:ncj, sc from nxts where not ntile within "az";
    ];

    queue:([]pos:enlist raze string til count starts;kys:enlist"";tplen:enlist 0);
    visited:([]pos:();kys:());
    while[0<count queue;
        minl:exec min tplen from queue;
        if[0<count found:select from queue where tplen=minl, count[allKeys]=count each kys; :exec first tplen from found];
        toExpand:select from queue where tplen=minl;
        visited,:delete tplen from toExpand;
        nxts:raze{[paths;needKey;e]
            raze{[paths;needKey;e;p]
                nxpos:select t,plen from paths where s=e[`pos;p], all each needKey[t] in e`kys;
                update npos:.[pos;(::;p);:;nxpos[`t]],tplen+nxpos[`plen], kys:asc each distinct each (kys,'nxpos[`t]) from count[nxpos]#enlist e
            }[paths;needKey;e]each til count e`pos
        }[paths;needKey]each toExpand;
        nxts:select from nxts where not ([]pos:npos;kys) in visited;
        queue:(delete from queue where tplen=minl),select pos:npos, kys, tplen from nxts;
        queue:0!select min tplen by kys,pos from queue;
    ];
    "not found"};

d18p2:{
    bpos:first raze til[count x],/:'where each x="@";
    x:.[;;:;]/[x;bpos+/:{x cross x} -1 0 1;"@#@###@#@"];
    d18p1 x};

/
x:();
x,:enlist"#########";
x,:enlist"#b.A.@.a#";
x,:enlist"#########";

x2:();
x2,:enlist"########################";
x2,:enlist"#f.D.E.e.C.b.A.@.a.B.c.#";
x2,:enlist"######################.#";
x2,:enlist"#d.....................#";
x2,:enlist"########################";

x3:();
x3,:enlist"########################";
x3,:enlist"#...............b.C.D.f#";
x3,:enlist"#.######################";
x3,:enlist"#.....@.a.B.c.d.A.e.F.g#";
x3,:enlist"########################";

x4:();
x4,:enlist"#################";
x4,:enlist"#i.G..c...e..H.p#";
x4,:enlist"########.########";
x4,:enlist"#j.A..b...f..D.o#";
x4,:enlist"########@########";
x4,:enlist"#k.E..a...g..B.n#";
x4,:enlist"########.########";
x4,:enlist"#l.F..d...h..C.m#";
x4,:enlist"#################";

x5:();
x5,:enlist"########################";
x5,:enlist"#@..............ac.GI.b#";
x5,:enlist"###d#e#f################";
x5,:enlist"###A#B#C################";
x5,:enlist"###g#h#i################";
x5,:enlist"########################";

x6:();
x6,:enlist"#######";
x6,:enlist"#a.#Cd#";
x6,:enlist"##...##";
x6,:enlist"##.@.##";
x6,:enlist"##...##";
x6,:enlist"#cB#Ab#";
x6,:enlist"#######";

x7:();
x7,:enlist"###############";
x7,:enlist"#d.ABC.#.....a#";
x7,:enlist"######...######";
x7,:enlist"######.@.######";
x7,:enlist"######...######";
x7,:enlist"#b.....#.....c#";
x7,:enlist"###############";

x8:();
x8,:enlist"#############";
x8,:enlist"#DcBa.#.GhKl#";
x8,:enlist"#.###...#I###";
x8,:enlist"#e#d#.@.#j#k#";
x8,:enlist"###C#...###J#";
x8,:enlist"#fEbA.#.FgHi#";
x8,:enlist"#############";

x9:();
x9,:enlist"#############";
x9,:enlist"#g#f.D#..h#l#";
x9,:enlist"#F###e#E###.#";
x9,:enlist"#dCba...BcIJ#";
x9,:enlist"#####.@.#####";
x9,:enlist"#nK.L...G...#";
x9,:enlist"#M###N#H###.#";
x9,:enlist"#o#m..#i#jk.#";
x9,:enlist"#############";

d18p1 x     //8
d18p1 x2    //86
d18p1 x3    //132
d18p1 x4    //136
d18p1 x5    //81

/d18p2 x
d18p2 x6    //8
d18p2 x7    //24
d18p2 x8    //32
d18p2 x9    //72

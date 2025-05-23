d22p1:{
    a:" "vs/:x;
    on:a[;0] like "on";
    pos:"I"$".."vs/:/:last each/:"="vs/:/:","vs/:last each a;
    state:101 101 101#0b;
    pos+:50;
    state:{[state;on1;pos1]
        ind:pos1[;0]+til each 1+pos1[;1]-pos1[;0];
        if[any 100<first each ind; :state];
        if[any 0>last each ind; :state];
        .[state;ind;:;on1]}/[state;on;pos];
    sum sum sum state};

d22p2:{
    a:" "vs/:x;
    on:a[;0] like "on";
    pos:"J"$".."vs/:/:last each/:"="vs/:/:","vs/:last each a;
    st:update x2+1, y2+1, z2+1, on from flip`x1`x2`y1`y2`z1`z2!flip raze each pos;
    xs:exec asc distinct (x1,x2) from st;
    ys:exec asc distinct (y1,y2) from st;
    zs:exec asc distinct (z1,z2) from st;
    st:update x1:xs?x1, x2:xs?x2, y1:ys?y1, y2:ys?y2, z1:zs?z1, z2:zs?z2 from st;
    st:{[st1;row]
        st1:update intersect:not(x1>=row`x2) or (x2<=row`x1) or (y1>=row`y2)
            or (y2<=row`y1) or (z1>=row`z2) or (z2<=row`z1) from st1;
        sti:delete intersect from select from st1 where intersect;
        stn:delete intersect from select from st1 where not intersect;
        xs1:asc distinct exec (x1,x2,row`x1`x2) from sti;
        ys1:asc distinct exec (y1,y2,row`y1`y2) from sti;
        zs1:asc distinct exec (z1,z2,row`z1`z2) from sti;
        splitOn:{[xs1;ys1;zs1;row1]
            nxs:xs1 where (xs1>=row1[`x1]) and xs1<=row1[`x2];
            nys:ys1 where (ys1>=row1[`y1]) and ys1<=row1[`y2];
            nzs:zs1 where (zs1>=row1[`z1]) and zs1<=row1[`z2];
            axs:(-1_nxs),'1_nxs; ays:(-1_nys),'1_nys; azs:(-1_nzs),'1_nzs;
            xt:flip`x1`x2!flip axs; yt:flip`y1`y2!flip ays; zt:flip`z1`z2!flip azs;
            update on:row1`on from (xt cross yt)cross zt};
        st1:stn,raze splitOn[xs1;ys1;zs1] each sti,row;
        st1:select from (0!select last on by x1,x2,y1,y2,z1,z2 from st1) where on;
        st1}/[delete from st;st];
    exec sum(xs[x2]-xs[x1])*(ys[y2]-ys[y1])*(zs[z2]-zs[z1]) from st};

/
d22p2 "\n"vs"on x=1..1,y=0..0,z=0..1\non x=0..0,y=0..0,z=1..1\non x=0..1,y=0..0,z=0..1" //4
d22p2 "\n"vs"on x=0..1,y=0..0,z=0..0\non x=0..0,y=0..0,z=0..0"  //2

d22p2 "\n"vs"on x=0..9,y=0..9,z=0..9\non x=5..5,y=5..5,z=5..5"      //1000
d22p2 "\n"vs"on x=0..9,y=0..9,z=0..9\non x=5..14,y=5..5,z=5..5"     //1005
d22p2 "\n"vs"on x=0..9,y=0..9,z=0..9\non x=-5..4,y=5..5,z=5..5"     //1005
d22p2 "\n"vs"on x=0..9,y=0..9,z=0..9\non x=5..5,y=-5..4,z=5..5"     //1005
d22p2 "\n"vs"on x=0..9,y=0..9,z=0..9\non x=5..5,y=5..14,z=5..5"     //1005
d22p2 "\n"vs"on x=0..9,y=0..9,z=0..9\non x=5..5,y=5..5,z=-5..4"     //1005
d22p2 "\n"vs"on x=0..9,y=0..9,z=0..9\non x=5..5,y=5..5,z=5..14"     //1005
d22p2 "\n"vs"on x=0..9,y=0..9,z=0..9\non x=-5..14,y=5..5,z=5..5"    //1010
d22p2 "\n"vs"on x=0..9,y=0..9,z=0..9\non x=5..5,y=-5..14,z=5..5"    //1010
d22p2 "\n"vs"on x=0..9,y=0..9,z=0..9\non x=5..5,y=5..5,z=-5..14"    //1010

d22p2 "\n"vs"on x=0..9,y=0..9,z=0..9\noff x=5..5,y=5..5,z=5..5"     //999
d22p2 "\n"vs"on x=0..9,y=0..9,z=0..9\noff x=5..20,y=5..5,z=5..5"    //995
d22p2 "\n"vs"on x=0..9,y=0..9,z=0..9\noff x=-5..4,y=5..5,z=5..5"    //995
d22p2 "\n"vs"on x=0..9,y=0..9,z=0..9\noff x=5..5,y=-5..4,z=5..5"    //995
d22p2 "\n"vs"on x=0..9,y=0..9,z=0..9\noff x=5..5,y=5..15,z=5..5"    //995
d22p2 "\n"vs"on x=0..9,y=0..9,z=0..9\noff x=5..5,y=5..5,z=-5..4"    //995
d22p2 "\n"vs"on x=0..9,y=0..9,z=0..9\noff x=5..5,y=5..5,z=5..15"    //995
d22p2 "\n"vs"on x=0..9,y=0..9,z=0..9\noff x=-5..14,y=5..5,z=5..5"   //990
d22p2 "\n"vs"on x=0..9,y=0..9,z=0..9\noff x=5..5,y=-5..14,z=5..5"   //990
d22p2 "\n"vs"on x=0..9,y=0..9,z=0..9\noff x=5..5,y=5..5,z=-5..14"   //990

d22p2 "\n"vs"on x=0..9,y=0..9,z=0..9\noff x=4..6,y=4..6,z=4..6" //973
d22p2 "\n"vs"on x=0..9,y=0..9,z=0..9\noff x=4..6,y=4..6,z=4..6\non x=5..5,y=5..5,z=5..5"    //974

x:enlist"on x=-20..26,y=-36..17,z=-47..7";
x,:enlist"on x=-20..33,y=-21..23,z=-26..28";
x,:enlist"on x=-22..28,y=-29..23,z=-38..16";
x,:enlist"on x=-46..7,y=-6..46,z=-50..-1";
x,:enlist"on x=-49..1,y=-3..46,z=-24..28";
x,:enlist"on x=2..47,y=-22..22,z=-23..27";
x,:enlist"on x=-27..23,y=-28..26,z=-21..29";
x,:enlist"on x=-39..5,y=-6..47,z=-3..44";
x,:enlist"on x=-30..21,y=-8..43,z=-13..34";
x,:enlist"on x=-22..26,y=-27..20,z=-29..19";
x,:enlist"off x=-48..-32,y=26..41,z=-47..-37";
x,:enlist"on x=-12..35,y=6..50,z=-50..-2";
x,:enlist"off x=-48..-32,y=-32..-16,z=-15..-5";
x,:enlist"on x=-18..26,y=-33..15,z=-7..46";
x,:enlist"off x=-40..-22,y=-38..-28,z=23..41";
x,:enlist"on x=-16..35,y=-41..10,z=-47..6";
x,:enlist"off x=-32..-23,y=11..30,z=-14..3";
x,:enlist"on x=-49..-5,y=-3..45,z=-29..18";
x,:enlist"off x=18..30,y=-20..-8,z=-3..13";
x,:enlist"on x=-41..9,y=-7..43,z=-33..15";
x,:enlist"on x=-54112..-39298,y=-85059..-49293,z=-27449..7877";
x,:enlist"on x=967..23432,y=45373..81175,z=27513..53682";

x2:enlist"on x=-5..47,y=-31..22,z=-19..33";
x2,:enlist"on x=-44..5,y=-27..21,z=-14..35";
x2,:enlist"on x=-49..-1,y=-11..42,z=-10..38";
x2,:enlist"on x=-20..34,y=-40..6,z=-44..1";
x2,:enlist"off x=26..39,y=40..50,z=-2..11";
x2,:enlist"on x=-41..5,y=-41..6,z=-36..8";
x2,:enlist"off x=-43..-33,y=-45..-28,z=7..25";
x2,:enlist"on x=-33..15,y=-32..19,z=-34..11";
x2,:enlist"off x=35..47,y=-46..-34,z=-11..5";
x2,:enlist"on x=-14..36,y=-6..44,z=-16..29";
x2,:enlist"on x=-57795..-6158,y=29564..72030,z=20435..90618";
x2,:enlist"on x=36731..105352,y=-21140..28532,z=16094..90401";
x2,:enlist"on x=30999..107136,y=-53464..15513,z=8553..71215";
x2,:enlist"on x=13528..83982,y=-99403..-27377,z=-24141..23996";
x2,:enlist"on x=-72682..-12347,y=18159..111354,z=7391..80950";
x2,:enlist"on x=-1060..80757,y=-65301..-20884,z=-103788..-16709";
x2,:enlist"on x=-83015..-9461,y=-72160..-8347,z=-81239..-26856";
x2,:enlist"on x=-52752..22273,y=-49450..9096,z=54442..119054";
x2,:enlist"on x=-29982..40483,y=-108474..-28371,z=-24328..38471";
x2,:enlist"on x=-4958..62750,y=40422..118853,z=-7672..65583";
x2,:enlist"on x=55694..108686,y=-43367..46958,z=-26781..48729";
x2,:enlist"on x=-98497..-18186,y=-63569..3412,z=1232..88485";
x2,:enlist"on x=-726..56291,y=-62629..13224,z=18033..85226";
x2,:enlist"on x=-110886..-34664,y=-81338..-8658,z=8914..63723";
x2,:enlist"on x=-55829..24974,y=-16897..54165,z=-121762..-28058";
x2,:enlist"on x=-65152..-11147,y=22489..91432,z=-58782..1780";
x2,:enlist"on x=-120100..-32970,y=-46592..27473,z=-11695..61039";
x2,:enlist"on x=-18631..37533,y=-124565..-50804,z=-35667..28308";
x2,:enlist"on x=-57817..18248,y=49321..117703,z=5745..55881";
x2,:enlist"on x=14781..98692,y=-1341..70827,z=15753..70151";
x2,:enlist"on x=-34419..55919,y=-19626..40991,z=39015..114138";
x2,:enlist"on x=-60785..11593,y=-56135..2999,z=-95368..-26915";
x2,:enlist"on x=-32178..58085,y=17647..101866,z=-91405..-8878";
x2,:enlist"on x=-53655..12091,y=50097..105568,z=-75335..-4862";
x2,:enlist"on x=-111166..-40997,y=-71714..2688,z=5609..50954";
x2,:enlist"on x=-16602..70118,y=-98693..-44401,z=5197..76897";
x2,:enlist"on x=16383..101554,y=4615..83635,z=-44907..18747";
x2,:enlist"off x=-95822..-15171,y=-19987..48940,z=10804..104439";
x2,:enlist"on x=-89813..-14614,y=16069..88491,z=-3297..45228";
x2,:enlist"on x=41075..99376,y=-20427..49978,z=-52012..13762";
x2,:enlist"on x=-21330..50085,y=-17944..62733,z=-112280..-30197";
x2,:enlist"on x=-16478..35915,y=36008..118594,z=-7885..47086";
x2,:enlist"off x=-98156..-27851,y=-49952..43171,z=-99005..-8456";
x2,:enlist"off x=2032..69770,y=-71013..4824,z=7471..94418";
x2,:enlist"on x=43670..120875,y=-42068..12382,z=-24787..38892";
x2,:enlist"off x=37514..111226,y=-45862..25743,z=-16714..54663";
x2,:enlist"off x=25699..97951,y=-30668..59918,z=-15349..69697";
x2,:enlist"off x=-44271..17935,y=-9516..60759,z=49131..112598";
x2,:enlist"on x=-61695..-5813,y=40978..94975,z=8655..80240";
x2,:enlist"off x=-101086..-9439,y=-7088..67543,z=33935..83858";
x2,:enlist"off x=18020..114017,y=-48931..32606,z=21474..89843";
x2,:enlist"off x=-77139..10506,y=-89994..-18797,z=-80..59318";
x2,:enlist"off x=8476..79288,y=-75520..11602,z=-96624..-24783";
x2,:enlist"on x=-47488..-1262,y=24338..100707,z=16292..72967";
x2,:enlist"off x=-84341..13987,y=2429..92914,z=-90671..-1318";
x2,:enlist"off x=-37810..49457,y=-71013..-7894,z=-105357..-13188";
x2,:enlist"off x=-27365..46395,y=31009..98017,z=15428..76570";
x2,:enlist"off x=-70369..-16548,y=22648..78696,z=-1892..86821";
x2,:enlist"on x=-53470..21291,y=-120233..-33476,z=-44150..38147";
x2,:enlist"off x=-93533..-4276,y=-16170..68771,z=-104985..-24507";

d22p1 x //590784
//d22p2 x
d22p2 x2    //2758514936282235

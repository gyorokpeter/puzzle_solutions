d22p1:{
    a:" "vs/:"\n"vs x;
    on:a[;0] like "on";
    pos:"I"$".."vs/:/:last each/:"="vs/:/:","vs/:last each a;
    state:101 101 101#0b;
    pos:pos+50;
    state:{[state;on1;pos1]
        ind:pos1[;0]+til each 1+pos1[;1]-pos1[;0];
        if[any 100<first each ind; :state];
        if[any 0>last each ind; :state];
        .[state;ind;:;on1]}/[state;on;pos];
    sum sum sum state};

d22p2:{
    a:" "vs/:"\n"vs x;
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
        st1:stn,(raze splitOn[xs1;ys1;zs1] each sti),splitOn[xs1;ys1;zs1;row];
        st1:select from (0!select last on by x1,x2,y1,y2,z1,z2 from st1) where on;
        st1}/[delete from st;st];
    exec sum(xs[x2]-xs[x1])*(ys[y2]-ys[y1])*(zs[z2]-zs[z1]) from st};

/
d22p2 x:"on x=1..1,y=0..0,z=0..1\non x=0..0,y=0..0,z=1..1\non x=0..1,y=0..0,z=0..1" //4
d22p2 x:"on x=0..1,y=0..0,z=0..0\non x=0..0,y=0..0,z=0..0" //2

d22p2 x:"on x=0..9,y=0..9,z=0..9\non x=5..5,y=5..5,z=5..5" //1000
d22p2 x:"on x=0..9,y=0..9,z=0..9\non x=5..14,y=5..5,z=5..5" //1005
d22p2 x:"on x=0..9,y=0..9,z=0..9\non x=-5..4,y=5..5,z=5..5" //1005
d22p2 x:"on x=0..9,y=0..9,z=0..9\non x=5..5,y=-5..4,z=5..5" //1005
d22p2 x:"on x=0..9,y=0..9,z=0..9\non x=5..5,y=5..14,z=5..5" //1005
d22p2 x:"on x=0..9,y=0..9,z=0..9\non x=5..5,y=5..5,z=-5..4" //1005
d22p2 x:"on x=0..9,y=0..9,z=0..9\non x=5..5,y=5..5,z=5..14" //1005
d22p2 x:"on x=0..9,y=0..9,z=0..9\non x=-5..14,y=5..5,z=5..5" //1010
d22p2 x:"on x=0..9,y=0..9,z=0..9\non x=5..5,y=-5..14,z=5..5" //1010
d22p2 x:"on x=0..9,y=0..9,z=0..9\non x=5..5,y=5..5,z=-5..14" //1010

d22p2 x:"on x=0..9,y=0..9,z=0..9\noff x=5..5,y=5..5,z=5..5" //999
d22p2 x:"on x=0..9,y=0..9,z=0..9\noff x=5..20,y=5..5,z=5..5" //995
d22p2 x:"on x=0..9,y=0..9,z=0..9\noff x=-5..4,y=5..5,z=5..5" //995
d22p2 x:"on x=0..9,y=0..9,z=0..9\noff x=5..5,y=-5..4,z=5..5" //995
d22p2 x:"on x=0..9,y=0..9,z=0..9\noff x=5..5,y=5..15,z=5..5" //995
d22p2 x:"on x=0..9,y=0..9,z=0..9\noff x=5..5,y=5..5,z=-5..4" //995
d22p2 x:"on x=0..9,y=0..9,z=0..9\noff x=5..5,y=5..5,z=5..15" //995
d22p2 x:"on x=0..9,y=0..9,z=0..9\noff x=-5..14,y=5..5,z=5..5" //990
d22p2 x:"on x=0..9,y=0..9,z=0..9\noff x=5..5,y=-5..14,z=5..5" //990
d22p2 x:"on x=0..9,y=0..9,z=0..9\noff x=5..5,y=5..5,z=-5..14" //990

d22p2 x:"on x=0..9,y=0..9,z=0..9\noff x=4..6,y=4..6,z=4..6" //973
d22p2 x:"on x=0..9,y=0..9,z=0..9\noff x=4..6,y=4..6,z=4..6\non x=5..5,y=5..5,z=5..5" //974

OVERVIEW:
Part 1 creates a 101*101*101 array to store the state of each coordinate and uses functional amend
to update it based on the instructions.

Part 2 required several rewrites to avoid hitting the memory limit. The final solution starts with
an empty list of cuboids, and when adding each new cuboid, it checks which existing ones it
intersects and splits both the existing ones and the new one by the list of start and end
coordinates of all the involved cuboids. This is also easier done by shifting the ending
coordinates by 1 so they point to the first position that is not inside the cuboid.
I also compressed the coordinates down to an index into the list of ascending coordinates. This was
only an optimization attempt for an earlier version that still hit the memory limit, but I left it
in regardless.

d17:{
    a:"J"$".."vs/:last each "="vs/:2_" "vs x except",";
    if[(a[0;0]<=0) or a[1;1]>=0; '"nyi"];
    xs:1+til a[0;1];
    xss:{0,sums reverse 1+til x}each xs;
    xsi:where any each xss within a[0];
    xs2:xs xsi;
    xss2:xss xsi;
    ys:a[1;0]+til 2*abs a[1;0];
    yss:{[lim;y]first each{[lim;yv]$[yv[0]<lim;yv;(yv[0]+yv[1];yv[1]-1)]}[lim]\[(0;y)]}[a[1;0]]each ys;
    ysi:where any each yss within a[1];
    ys2:ys ysi;
    yss2:yss ysi;
    f:{[a;r]
        xs:(min[count each r`xs`ys]#r`xs),(0|count[r`ys]-count[r`xs])#last r`xs;
        pos:xs,'r`ys;
        if[not any all each pos within'\: a; :()];
        enlist`xv`yv`pos!(r`xv;r`yv;max pos[;1])}[a];
    shots:raze f each([]xv:xs2;xs:xss2)cross([]yv:ys2;ys:yss2);
    shots};
d17p1:{exec max pos from d17[x]};
d17p2:{count d17[x]};

/
d17p1 x:"target area: x=20..30, y=-10..-5"
d17p2 x

.d21.keypath:{[pad]
    nums:asc raze[pad]except" ";
    p:2!([]s:nums)cross([]t:nums;press:count[nums]#enlist());
    p:update press:count[i]#enlist enlist"" from p where s=t;
    queue:([]pos:raze til[count pad],/:\:til[count first pad];path:0N 1#raze pad);
    queue:update press:count[i]#enlist"" from queue;
    queue:delete from queue where " "=last each path;
    while[count queue;
        nxts:raze{([]pos:x[`pos]+/:(-1 0;0 1;1 0;0 -1);path:4#enlist x`path;press:x[`press],/:"^>v<")}each queue;
        nxts:update path:(path,'pad ./:pos) from nxts;
        nxts:delete from nxts where " "=last each path;
        nxts:delete from nxts where (count each path)<>count each distinct each path;
        nxts:delete from nxts where 0b~/:@[`p#;;{0b}]each press;
        nxts:delete from nxts where all each"<>"in/:press;
        nxts:delete from nxts where all each"^v"in/:press;
        np:select press2:press by s:first each path,t:last each path from nxts;
        p:delete press2 from update press:(press,'press2) from p,'np where 0<count each first each press2;
        queue:nxts;
    ];
    exec (t,'s)!(press,\:\:"A") from p};
.d21.kpNum:.d21.keypath("789";"456";"123";" 0A");
.d21.kpArrow:.d21.keypath(" ^A";"<v>");
.d21.keypathExt:{[seq]
    f:{cross/[{.d21.kpArrow[x,y]}':["A",x]]};
    press:f each/:seq;
    press2:f each/:/:press;
    cs:count each/:/:/:press2;
    cs2:min each/:min each/:cs;
    seq@'first each where each cs2=min each cs2};
.d21.kpNumExt:.d21.keypathExt[.d21.kpNum];
.d21.kpArrowExt:.d21.keypathExt[.d21.kpArrow];
.d21.single:{[iter;seq]
    f:{[x;p]count each enlist[""]_group{x y,z}[p]':["A",x]};
    press:f[seq;.d21.kpNumExt];
    do[iter+1;
        press:sum(f[;.d21.kpArrowExt]each key press)*value press;
    ];
    sum(count each key press)*value press};
d21:{[iter;x]
    sum(.d21.single[iter]each x)*"J"$x except\:"A"};
d21p1:{d21[1;x]};
d21p2:{d21[24;x]};

/

x:"\n"vs"029A\n980A\n179A\n456A\n379A";

d21p1 x //126384
d21p2 x //154115708116294

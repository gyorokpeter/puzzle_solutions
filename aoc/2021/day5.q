d5p1:{
    a:asc each "J"$","vs/:/:" -> "vs/:"\n"vs x;
    h:a where a[;0;1]=a[;1;1];
    v:a where a[;0;0]=a[;1;0];
    hp:raze(h[;0;0]+til each 1+h[;1;0]-h[;0;0]),\:'h[;0;1];
    vp:raze v[;0;0],/:'v[;0;1]+til each 1+v[;1;1]-v[;0;1];
    sum 1<count each group hp,vp};
d5p2:{
    a:asc each "J"$","vs/:/:" -> "vs/:"\n"vs x;
    diff:a[;1]-a[;0];
    dir:diff div max each abs diff;
    len:1+max each diff div dir;
    pts:raze a[;0]+/:'(til each len)*\:'dir;
    sum 1<count each group pts};

/
x:"0,9 -> 5,9\n8,0 -> 0,8\n9,4 -> 3,4\n2,2 -> 2,1\n7,0 -> 7,4\n6,4 -> 2,0\n0,9 -> 2,9\n3,4 -> 1,4"
x,:"\n0,0 -> 8,8\n5,5 -> 8,2"
d5p1 x
d5p2 x

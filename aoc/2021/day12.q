d12p1:{
    a:flip`$"-"vs/:"\n"vs x;
    edges:exec t by s from (flip`s`t!a),flip`t`s!a;
    cap:{x where x=upper x}key edges;
    queue:enlist enlist`start;
    paths:();
    while[0<count queue;
        nxts:`p`n!/:raze queue(;)/:'edges last each queue;
        nxts:delete from nxts where n in' p, not n in cap;
        paths,:exec (p,'n) from nxts where n=`end;
        nxts:delete from nxts where n=`end;
        queue:exec (p,'n) from nxts;
    ];
    count paths};

d12p2:{
    a:flip`$"-"vs/:"\n"vs x;
    edges:exec t by s from (flip`s`t!a),flip`t`s!a where t<>`start;
    cap:{x where x=upper x}key edges;
    small:({x where x=lower x}key edges)except `start`end;
    queue:([]p:enlist enlist`start;sm:0b);
    paths:();
    while[0<count queue;
        nxts:update n:edges[last each p] from queue;
        nxts:raze{([]p:count[x`n]#enlist x`p;sm:x`sm;n:x`n)}each nxts;
        nxts:delete from nxts where n in' p, not n in cap, sm;
        nxts:update sm:1b from nxts where n in' p, not n in cap;
        paths,:exec (p,'n) from nxts where n=`end;
        nxts:delete from nxts where n=`end;
        queue:select p:(p,'n), sm from nxts;
    ];
    count paths};

/


d12p1 x:"start-A\nstart-b\nA-c\nA-b\nb-d\nA-end\nb-end"
d12p2 x

x:"dc-end\nHN-start\nstart-kj\ndc-start\ndc-HN\nLN-dc\nHN-end\nkj-sa\nk";
x,:"j-HN\nkj-dc";
d12p1 x
d12p2 x

x:"fs-end\nhe-DX\nfs-he\nstart-DX\npj-DX\nend-zg\nzg-sl\nzg-pj\npj-he\nR";
x,:"W-he\nfs-DX\npj-RW\nzg-RW\nstart-pj\nhe-WI\nzg-he\npj-fs\nstart-RW";
d12p1 x
d12p2 x

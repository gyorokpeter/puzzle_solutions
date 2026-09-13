d22:{[rules;step;map]
    mpdt:{[rules;x]map:x 0;pos:x 1;dir:x 2;total:x 3;
        if[pos[0]=-1; pos[0]:0; map:(enlist count[first map]#"."),map];
        if[pos[1]=-1; pos[1]:0; map:".",/:map];
        if[pos[0]>=count map; map:map,(enlist count[first map]#".")];
        if[pos[1]>=count first map; map:map,\:"."];
        rule:rules map . pos;
        dir:(dir+rule 1)mod 4;
        map[pos 0;pos 1]:rule 0;
        total+:"#"=rule 0;
        pos+:(-1 0;0 1;1 0;0 -1)dir;
    (map;pos;dir;total)}[rules]/[step;(map;2#count[map]div 2;0;0)];
    last mpdt};

d22p1:{rules:".#"!(("#";-1);(".";1));step:10000;d22[rules;step;x]};
d22p2:{rules:".W#F"!(("W";-1);("#";0);("F";1);(".";2));step:10000000;d22[rules;step;x]};

/
map:x:"\n"vs"..#\n#..\n...";

d22p1 x //5587
d22p2 x //2511944

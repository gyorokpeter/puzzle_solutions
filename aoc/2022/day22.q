d22p1:{a:"\n\n"vs"\n"sv x;
    map:"\n"vs a 0;
    path:{(0,where 0<>deltas x in "LR")cut x}a 1;
    pos:0,(first where "."=map[0]),0;
    pos:{[map;pos;ins]
        $[ins~enlist"L"; pos[2]:(pos[2]-1)mod 4;
          ins~enlist"R"; pos[2]:(pos[2]+1)mod 4;
          [
            amt:"J"$ins;
            dir:pos 2;
            row:$[dir=0; map[pos 0];
                dir=1; map[;pos 1];
                dir=2; reverse map[pos 0];
                dir=3; reverse map[;pos 1]];
            actpos:$[dir=0; pos 1;
                dir=1; pos 0;
                dir=2; count[map pos 0]-1+pos 1;
                dir=3; count[map]-1+pos 0];
            ofs:first where " "<>row;
            row:trim row;
            actpos-:ofs;
            actpos+:(amt and 0W^-1+first where "#"=(amt+1)#actpos rotate row);
            actpos:actpos mod count row;
            actpos+:ofs;
            $[dir=0; pos[1]:actpos;
                dir=1; pos[0]:actpos;
                dir=2; pos[1]:count[map pos 0]-1+actpos;
                dir=3; pos[0]:count[map]-1+actpos];
          ]
        ];
        pos}[map]/[pos;path];
    sum 1000 4 1*1 1 0+pos};

d22p2:{a:"\n\n"vs"\n"sv x;
    map:"\n"vs a 0;
    path:{(0,where 0<>deltas x in "LR")cut x}a 1;
    pos:0,(first where "."=map[0]),0;
    map:max[count each map]$map;
    wrap:.d22.genAdjacency[map];
    pos:{[map;wrap;pos;ins]
        $[ins~enlist"L"; pos[2]:(pos[2]-1)mod 4;
          ins~enlist"R"; pos[2]:(pos[2]+1)mod 4;
          [
            amt:"J"$ins;
            do[amt;
                prevpos:pos;
                pos:$[pos in key wrap;wrap pos;(.d22.direction[pos 2],0)+pos];
                if["#"=map . 2#pos; pos:prevpos];
            ];
          ]
        ];
    pos}[map;wrap]/[pos;path];
    sum 1000 4 1*1 1 0+pos};

//https://github.com/taylorott/Advent_of_Code/blob/main/src/Year_2022/Day22/Solution.py

.d22.onExterior:{[map;pos](pos[0]<0) or (pos[1]<0) or (pos[0]>=count map) or (pos[1]>=count map 0) or " "=map . pos};
.d22.onInterior:{[map;pos]not .d22.onExterior[map;pos]};

.d22.perimeterStep:{[map;pos;dir]
    nextpos:pos+.d22.direction[dir];
    if[.d22.onExterior[map;nextpos];
        dirL:(dir-1)mod 4;
        nextposL:pos+.d22.direction[dirL];
        dirR:(dir+1)mod 4;
        nextposR:pos+.d22.direction[dirR];
        if[.d22.onInterior[map;nextposL]; :(pos;dirL)];
        if[.d22.onInterior[map;nextposR]; :(pos;dirR)];
    ];
    (nextpos;dir)};

.d22.zipEdgesFromCorner:{[map;pos;dirp]
    dir0:dirp 0;
    dir1:dirp 1;
    dir0p:dir0;
    dir1p:dir1;
    pos0:pos+.d22.direction[dir0];
    pos1:pos+.d22.direction[dir1];
    res:enlist[`int$()]!enlist`int$();
    while[(dir0p=dir0) or dir1p=dir1;
        dir0p:dir0;
        dir1p:dir1;
        normout0:(dir0+1)mod 4;
        if[.d22.onInterior[map;pos0+.d22.direction[normout0]];
            normout0:(dir0-1)mod 4;
        ];
        normout1:(dir1+1)mod 4;
        if[.d22.onInterior[map;pos1+.d22.direction[normout1]];
            normout1:(dir1-1)mod 4;
        ];
        normin0:(normout0+2)mod 4;
        normin1:(normout1+2)mod 4;
        res[pos0,normout0]:pos1,normin1;
        res[pos1,normout1]:pos0,normin0;
        r0:.d22.perimeterStep[map;pos0;dir0];
        r1:.d22.perimeterStep[map;pos1;dir1];
        pos0:first r0; dir0:last r0;
        pos1:first r1; dir1:last r1;
    ];
    1_res};

.d22.genAdjacency:{[map]
    filler:enlist count[first map]#" ";
    diag:((1_(1_/:map),\:" "),filler;
        (1_" ",/:-1_/:map),filler;
        filler,-1_" ",/:-1_/:map;
        filler,-1_(1_/:map),\:" ");
    ortho:(1_/:map,\:" ";
        (1_map),filler;
        " ",/:-1_/:map;
        filler,-1_map);
    corner:raze til[count map],/:'where each(1=sum diag=" ")and 0=sum ortho=" ";
    corner:corner(;)'{x,'(x+1)mod 4}where each " "=diag .\:/:corner;
    raze .d22.zipEdgesFromCorner[map].'corner};

.d22.direction:(0 1;1 0;0 -1;-1 0);

/

x:"\n"vs"        ...#\n        .#..\n        #...\n        ....\n...#.......#\n........#...\n..#....#....\n..........#.\n        ...#....\n        .....#..\n        .#......\n        ......#.\n\n10R5L5R10L4R5L5";

d22p1 x //6032
d22p2 x //5031

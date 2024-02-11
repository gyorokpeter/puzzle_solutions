.d23.cost:1 10 100 1000;
.d23.fmt:{[node]rooms:flip {(neg max count each x)$x}1_node;
    ("#############";"#",node[0],"#";"###",raze[rooms[0],'"#"],"##")
    ,({"  #",raze[x,'"#"],"  "}each 1_rooms),enlist"  #########  "};

.d23.expand:{[roomSize;row]
    node:row`node;
    waitPos:where node[0]<>" ";
    rooms:1_node;

    canMoveOut:(not all each rooms="ABCD") and 0<count each rooms;
    moveOutInd:where canMoveOut;
    if[0<count moveOutInd;
        moveOutPos:2+2*moveOutInd;
        moveOutLetter:first each rooms moveOutInd;
        moveOutId:"ABCD"?moveOutLetter;
        moveOutRow:1+(roomSize-count each rooms)moveOutInd;
        gol:((moveOutPos-1)-where each" "=fills each reverse each moveOutPos#\:node 0)except\:2 4 6 8;
        gor:(moveOutPos+1+where each" "=fills each (moveOutPos+1)_\:node 0)except\:2 4 6 8;
        golc:(moveOutRow+moveOutPos-gol)*.d23.cost moveOutId;
        gorc:(moveOutRow+gor-moveOutPos)*.d23.cost moveOutId;
        nodes:@[node;;1_]each 1+moveOutInd;
        nodes2:raze{[node;letter;go]{[node;letter;go].[node;(0;go);:;letter]}[node;letter]each go}'[nodes;moveOutLetter;gol,'gor];
        moveOut:([]node:nodes2;len:row[`len]+raze golc,'gorc);
    ];
    if[0<count waitPos;
        waitLetter:node[0;waitPos];
        waitId:"ABCD"?waitLetter;
        openRoom:where all each rooms="ABCD";
        canMoveInInd:where waitId in openRoom;
        canMoveInPos:waitPos canMoveInInd;
        canMoveInId:waitId canMoveInInd;
        canMoveInRow:(roomSize-count each rooms) canMoveInId;
        moveInDelta:(2*1+canMoveInId)-canMoveInPos;
        moveInPath:canMoveInPos+signum[moveInDelta]*1+til each abs moveInDelta;
        pathClearInd:where 0=count each moveInPath inter\:waitPos;
        canMoveInPos2:canMoveInPos pathClearInd;
        canMoveInRow2:canMoveInRow pathClearInd;
        canMoveInId2:canMoveInId pathClearInd;
        nodes:{[node;pos].[node;(0;pos);:;" "]}[node]each canMoveInPos2;
        nodes2:{[node;id]@[node;1+id;("ABCD"id),]}'[nodes;canMoveInId2];
        moveIn:([]node:nodes2;len:row[`len]+(abs[canMoveInPos2-2+2*canMoveInId2]+canMoveInRow2)*.d23.cost canMoveInId2);
    ];
    moveOut,moveIn};

d23:{[part;x]
    a:"\n"vs x;
    rooms:enlist[a[2;3 5 7 9]],$[part=2;("DCBA";"DBAC");()],enlist a[3;3 5 7 9];
    roomSize:$[part=2;4;2];
    b:enlist[11#" "],flip rooms;
    goal:enlist[11#" "],flip roomSize#enlist"ABCD";
    queue:([]node:enlist[b];len:enlist 0);
    while[0<count queue;
        nxts:select from queue where len=min len;
        -1 string[count queue]," ",string min nxts`len;
        if[goal in nxts`node; :first nxts`len];
        queue:delete from queue where len=min len;
        nxts2:raze .d23.expand[roomSize] each nxts;
        queue:0!select min len by node from queue,nxts2;
    ];
    '"no solution"};
d23p1:{d23[1;x]};
d23p2:{d23[2;x]};

/
d23p1 x:"#############\n#...........#\n###B#C#B#D###\n  #A#D#C#A#\n  #########"
d23p2 x

OVERVIEW:
This is an implementation of Dijkstra's algorithm. Due to how fiddly the implementation is for
expanding nodes, this requires a lambda each with lots of steps to expand each node, and there is
a high number of nodes to expand, which kills the performance. It simplifies the implementation to
store each room as a list rather than keeping the initial 2d representation of the field.

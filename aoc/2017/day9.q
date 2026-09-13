d9p1:{a:first x;
    b:ssr[a;"!?";".."];
    g:`boolean$fills(0,-1_0N 0 b=">")^0N 1 b="<";
    c:?[g;".";b];
    sum sums[("{}"!1 -1)c]*c="{"};
d9p2:{a:first x;
    b:ssr[a;"!?";".."];
    g:`boolean$fills(0,-1_0N 1 b="<")^0N 0 b=">";
    sum?[g;b;"."]<>"."};

d9p2:{
    total:0;
    garbage:0b;
    while[0<count x;
        $[
          not[garbage] and "<"=first x;
            garbage:1b;
          "!"=first x;
            x:1_x;
          ">"=first x;
            garbage:0b;
          garbage;
            total+:1;
          "{"=first x;
            ::;
          "}"=first x;
            ::;
        ::];
        x:1_x;
    ];
    total};

/
d9p1 enlist"{}"    //1
d9p1 enlist"{{{}}}"    //6
d9p1 enlist"{{},{}}"   //5
d9p1 enlist"{{{},{},{{}}}}"    //16
d9p1 enlist"{<a>,<a>,<a>,<a>}" //1
d9p1 enlist"{{<ab>},{<ab>},{<ab>},{<ab>}}" //9
d9p1 enlist"{{<!!>},{<!!>},{<!!>},{<!!>}}" //9
d9p1 enlist"{{<a!>},{<a!>},{<a!>},{<ab>}}" //3

d9p2 enlist"<>"    //0
d9p2 enlist"<random characters>"   //17
d9p2 enlist"<<<<>" //3
d9p2 enlist"<{!>}>"    //2
d9p2 enlist"<!!>"  //0
d9p2 enlist"<!!!>>"    //0
d9p2 enlist"<{o\"i!a,<{i<a>"   //10

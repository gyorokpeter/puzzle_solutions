d23:{[cups;moves;rlen;rmode;x]
    c:-1+"J"$/:x;
    c,:count[c]_til cups;
    right:c((c?til count c)+1)mod count c;
    curr:first c;
    round:0;
    do[moves;
        round+:1;
        move:1_right\[3;curr];
        dest:first ((curr-1+til 4)mod count c)except move;
        after:right last move;
        aftd:right dest;
        right[(curr;dest;last move)]:(after;first move;aftd);
        curr:right curr;
        if[0=round mod 10000; show round];
    ];
    $[rmode=`mult;prd;raze string@]1+1_right\[$[0=rlen;count[c]-1;rlen];0]};
d23p1:{d23[0;100;0;`str;x]};
d23p2:{d23[1000000;10000000;2;`mult;x]};

/

// No input file, input is a string.
x:"389125467";

d23p1 x //"67384529"
d23p2 x //149245887792  //warning: slow

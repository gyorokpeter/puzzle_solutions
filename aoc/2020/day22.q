d22p1:{decks:"J"$1_/:"\n"vs/:"\n\n"vs"\n"sv x;
    while[0<prd count each decks;
        $[decks[0;0]>decks[1;0];
            decks:((1_decks[0]),decks[0;0],decks[1;0];1_decks[1]);
            decks:(1_decks[0];(1_decks[1]),decks[1;0],decks[0;0])];
        ];
    cards:reverse raze decks;
    sum(1+til count cards)*cards};
d22p2:{decks:"J"$1_/:"\n"vs/:"\n\n"vs"\n"sv x;
    memo:();
    stack:();
    while[0<prd count each decks;
        $[first enlist[decks] in memo;
            decks[1]:`long$();
          any(first each decks)>-1+count each decks;
            [memo,:enlist decks;
            $[decks[0;0]>decks[1;0];
                decks:((1_decks[0]),decks[0;0],decks[1;0];1_decks[1]);
                decks:(1_decks[0];(1_decks[1]),decks[1;0],decks[0;0])];
            ];
          [stack:stack,enlist(memo;decks);memo:();decks:decks[;0]#'1_/:decks]];
        if[0<count stack;if[any 0=count each decks;
            winner:first where 0<count each decks;
            memo:first last stack;
            decks:last last stack;
            stack:-1_stack;
            memo,:enlist decks;
            moveCards:decks[winner;0],decks[1-winner;0];
            decks:(1_/:decks);
            decks[winner],:moveCards;
        ]];
    ];
    cards:reverse raze decks;
    sum(1+til count cards)*cards};

/
x:();
x,:"\n"vs"Player 1:\n9\n2\n6\n3\n1\n";
x,:"\n"vs"Player 2:\n5\n8\n4\n7\n10";

d22p1 x //306
d22p2 x //291

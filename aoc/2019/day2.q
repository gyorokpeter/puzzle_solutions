d2:{[a;n;v]
    a[1 2]:(n;v);
    ip:0;
    while[a[ip]<>99;
        $[a[ip]=1; [a[a ip+3]:a[a ip+1]+a[a ip+2]; ip+:4];
          a[ip]=2; [a[a ip+3]:a[a ip+1]*a[a ip+2]; ip+:4];
          '"invalid op"
        ];
    ];
    a[0]};
d2p1:{a:"J"$","vs raze x; d2[a;12;2]};
d2p2:{a:"J"$","vs raze x; 
    b:til[100]d2[a]/:\:til[100];
    c:first raze til[100],/:'where each b=19690720;
    (100*c[0])+c[1]};

/
No example input provided

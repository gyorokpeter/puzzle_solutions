d3p1:{a:max each -1_/:x;
    b:max each(1+first each where each x='a)_'x;
    sum"J"$a,'b};
d3p2:{n:12;
    r:0#/:x;
    x1:x;
    while[n>0;
        n-:1;
        a:max each neg[n]_/:x1;
        r:r,'a;
        x1:(1+first each where each x1='a)_'x1;
    ];
    sum"J"$r};

/
x:"\n"vs"987654321111111\n811111111111119\n234234234234278\n818181911112111";

d3p1 x  //357
d3p2 x  //3121910778619

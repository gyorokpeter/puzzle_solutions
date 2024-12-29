d11:{[steps;x]
    n:"J"$" "vs first x;
    t:{([]n:key x;c:value x)}count each group n;
    f:{(),$[0=x;1;0=count[s:10 vs x]mod 2;10 sv/:2 0N#s;2024*x]};
    g:{[f;x]select sum c by n from ungroup update f each n from x}[f];
    exec sum c from g/[steps;t]};
d11p1:{d11[25;x]};
d11p2:{d11[75;x]};

/

x:enlist"125 17";

d11p1 x //55312
d11p2 x //65601038650482

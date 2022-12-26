d8p1:{a:"J"$/:/:x;
    f:{x>maxs each -1_/:-1,/:x};
    sum sum max(f a; flip f flip a; reverse flip f flip reverse a; reverse each f reverse each a)};
d8p2:{a:"J"$/:/:x;
    op:{[m;x]0,/:{[m;x;y]$[y<m;x+1;1]}[m]\[0;]each -1_/:x};
    op2:{[op;m;x]prd(op[m]x; flip op[m] flip x; reverse flip op[m] flip reverse x; reverse each op[m] reverse each x)}[op];
    op3:{[op2;x;m]op2[m;x]*m=x}[op2];
    max max sum op3[a] each til 10};

/
x:"\n"vs"30373\n25512\n65332\n33549\n35390";

d8p1 x  //21
d8p2 x  //8

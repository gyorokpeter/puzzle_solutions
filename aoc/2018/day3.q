d3parse:{"J"$",x"vs'/:": "vs/:last each"@ "vs/:x};
d3p1:{a:d3parse x;b:raze{x[0]+/:til[x[1;0]]cross til x[1;1]}each a;sum 1<count each group b};
d3p2:{a:d3parse x;b:{x[0]+/:til[x[1][0]]cross til x[1][1]}each a;c:where 1=count each group raze b;first 1+where all each b in c};

/
x:"\n"vs"#1 @ 1,3: 4x4\n#2 @ 3,1: 4x4\n#3 @ 5,5: 2x2";

d3p1 x  //4
d3p2 x  //3
d5p1:{s:"J"$x;p:0;c:0;while[p within (0;count[s]-1);np:p+s p;s[p]+:1;p:np;c+:1];c};
d5p2:{s:"J"$x;p:0;c:0;while[p within (0;count[s]-1);np:p+s p;s[p]+:$[s[p]>=3;-1;1];p:np;c+:1];c};

/
d5p1 string 0 3 0 1 -3 //5
d5p2 string 0 3 0 1 -3 //10

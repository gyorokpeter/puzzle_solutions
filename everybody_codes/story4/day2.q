d2p1:{a:last each"="vs/:x; p:"J"$","vs/:1_/:-1_/:4#a;
    count distinct enlist[p 0],{floor(x+y)%2}\[p 0;p 1+"ABC"?last a]};
d2p2:{a:last each"="vs/:x; p:"J"$","vs/:1_/:-1_/:4#a;
    sq:distinct enlist[p 0],{floor(x+y)%2}\[p 0;p 1+"ABC"?last a];
    count distinct[raze sq+/:\:(0 -1;1 0;0 1;-1 0)]except sq};
d2p3:{a:last each"="vs/:x; p:"J"$","vs/:1_/:-1_/:4#a;
    sq:{[pp;pl]distinct pl,raze floor(pl+/:\:pp)%2}[p 1+til 3]/[enlist p 0];
    count distinct[raze sq+/:\:(0 -1;1 0;0 1;-1 0)]except sq};

/
x:();
x,:enlist"START=[5,0]";
x,:enlist"A=[0,0]";
x,:enlist"B=[10,0]";
x,:enlist"C=[5,10]";
x,:enlist"MOVES=ABCCBABCA";

x2:();
x2,:enlist"START=[5,0]";
x2,:enlist"A=[0,0]";
x2,:enlist"B=[10,0]";
x2,:enlist"C=[5,10]";
x2,:enlist"MOVES=BABCAABBCABCCCBBABCCCAAACABABCBCBBCAABBABBCACCBAABCBCBBBCBBBBBCCCAACAACB";

x3:();
x3,:enlist"START=[0,0]";
x3,:enlist"A=[0,0]";
x3,:enlist"B=[80,15]";
x3,:enlist"C=[5,30]";

d2p1 x  //8
d2p2 x  //25
d2p2 x2 //46
d2p3 x  //42
d2p3 x3 //432

d2p1 read0`:everybody_codes_e4_q02_p1.txt
d2p2 read0`:everybody_codes_e4_q02_p2.txt
d2p3 read0`:everybody_codes_e4_q02_p3.txt

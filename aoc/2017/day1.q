d1p1:{a:first x;sum 0,"J"$/:a where a=1 rotate a};
d1p2:{a:first x;sum 0,"J"$/:a where a=(count[a]div 2) rotate a};

/
d1p1 enlist"1122"   //3
d1p1 enlist"1111"   //4
d1p1 enlist"1234"   //0
d1p1 enlist"91212129"   //9

d1p2 enlist"1212"   //6
d1p2 enlist"1221"   //0
d1p2 enlist"123425" //4
d1p2 enlist"123123" //12
d1p2 enlist"12131415" //4

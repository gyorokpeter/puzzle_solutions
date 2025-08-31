d2:{update "J"$"-"vs/:num, first each ch from flip`num`ch`pw!flip" "vs/:x};
d2p1:{exec count i from d2[x] where (sum each pw=ch)within' num};
d2p2:{exec count i from d2[x] where 1=sum each ch=pw@'num-1};

/
x:"\n"vs"1-3 a: abcde\n1-3 b: cdefg\n2-9 c: ccccccccc";

d2p1 x  //2
d2p2 x  //1

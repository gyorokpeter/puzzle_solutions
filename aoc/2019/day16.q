d16p1:{
    a:`float$"J"$/:raze x;
    m:`float$1_/:(1+count[a])#/:raze each flip(1+til count a)#'/:0 1 0 -1;
    do[100;a:(abs m mmu a)mod 10];
    raze string 8#a};
d16p2:{
    a:"J"$/:raze x;
    off:10 sv 7#a;
    b:(off-10000*count[a])#a;
    c:reverse {sums[x]mod 10}/[100;reverse b];
    raze string 8#c};

/
x1:enlist"80871224585914546619083218645595"
x2:enlist"19617804207202209144916044189917"
x3:enlist"69317163492948606335995924319873"
x4:enlist"03036732577212944063491565474664"
x5:enlist"02935109699940807407585447034323"
x6:enlist"03081770884921959731165446850517"

//d16p1 x
d16p1 x1    //"24176176"
d16p1 x2    //"73745418"
d16p1 x3    //"52432133"

//d16p2 x
d16p2 x4    //"84462026"
d16p2 x5    //"78725270"
d16p2 x6    //"53553731"

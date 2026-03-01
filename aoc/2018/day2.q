d1p1:{prd sum{2 3 in count each group x}each x};
d1p2:{corr:x raze where each(count[first x]-1)=sum each/:x=/:\:x;
    corr[0]where(=). corr};

/
x:"\n"vs"abcdef\nbababc\nabbcde\nabcccd\naabcdd\nabcdee\nababab";
x2:"\n"vs"abcde\nfghij\nklmno\npqrst\nfguij\naxcye\nwvxyz";

d1p1 x  //12
//d1p2 x
d1p2 x2 //"fgij"

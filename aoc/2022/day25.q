d25:{digits:("=-012"!-2+til 5);
    s:5 vs sum 5 sv/:digits x;
    digits?{[s]if[first[s]>2; s:0,s];s+next[s>2]+(s>2)*-5}/[s]};

/
x:"\n"vs"1=-0-2\n12111\n2=0=\n21\n2=01\n111\n20012\n112\n1=-1=\n1-12\n12\n1=\n122";

d25 x //2=-1=0

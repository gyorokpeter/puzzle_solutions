d5p1:{
    s:first x;
    pairs:(.Q.a,.Q.A),'(.Q.A,.Q.a);
    s2:ssr[;;""]/[;pairs]/[s];
    count s2};
d5p2:{
    s:first x;
    as:s except/:.Q.a,'.Q.A;
    rs:d5p1 each enlist each as;
    min rs};

/
x:enlist"dabAcCaCBAcCcaDA";

d5p1 x  //10
d5p2 x  //4

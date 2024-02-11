d7p1:{
    a:"J"$","vs x;
    lo:min a;
    hi:max a;
    dest:lo+til 1+hi-lo;
    costs:sum each abs a-/:dest;
    min costs};
d7p2:{
    a:"J"$","vs x;
    lo:min a;
    hi:max a;
    dest:lo+til 1+hi-lo;
    offs:abs a-/:dest;
    maxOffs:max max offs;
    cost:sums til 1+maxOffs;
    costs:sum each cost offs;
    min costs};

/
d7p1 x:"16,1,2,0,4,2,7,1,2,14"
d7p2 x

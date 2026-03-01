d6prep:{
    c:reverse each"J"$", "vs/:x;
    c1:c-\:-1+min c;
    sz:2+max c1;
    grid:til[first sz],/:\:til[last sz];
    dist:sum each/:/:abs grid-\:\:/:c1;
    (dist;c1)};
d6p1:{
    cd:d6prep x;dist:cd 0;c1:cd 1;
    md:min dist;
    closest:where each/:flip each flip dist=\:md;
    unique:?'[1=count each/:closest;first each/:closest;0N];
    finite:til[count c1] except unique[0],last[unique],unique[;0],last each unique;
    finiteDist:sum each sum each unique=/:finite;
    max finiteDist};
d6p2:{[x;rng]
    dist:first d6prep x;
    sum sum sum[dist]<rng};

/
x:"\n"vs"1, 1\n1, 6\n8, 3\n3, 4\n5, 5\n8, 9";

d6p1 x  //17
d6p2[x;32]  //16
//d6p2[x;10000]

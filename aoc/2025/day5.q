d5p1:{a:"\n"vs/:"\n\n"vs"\n"sv x;
    sum any("J"$a[1])within/:"J"$"-"vs/:a[0]};
d5p2:{r:0 1+/:asc"J"$"-"vs/:first"\n"vs/:"\n\n"vs"\n"sv x;
    b:where[r[;0]>prev maxs r[;1]]cut r;
    sum neg(-)./:(min each b[;;0]),'(max each b[;;1])};

/
x:"\n"vs"3-5\n10-14\n16-20\n12-18\n\n1\n5\n8\n11\n17\n32";

d5p1 x  //3
d5p2 x  //14

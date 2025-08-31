d14p1:{
    st:{[st;x]$[x like "mask*";st[0]:(28#0N),"J"$/:last" "vs x;
        st[1;"J"$last"["vs first"]"vs x]:0b sv 1=(0b vs "J"$last" "vs x)^st[0]];
        st}/[(();()!());x];
    sum st 1};
d14p2:{
    st:{[st;x]$[x like "mask*";[m:last" "vs x;st[0]:28+where m="1";st[1]:28+where m="X"];
        [d:0b vs"J"$last"["vs first"]"vs x;d[st[0]]:1b;
            d:0b sv/:1=@[d;st[1];:;]each{x cross 01b}/[count[st[1]]-1;01b];
            st[2;d]:"J"$last" "vs x]];
        st}/[(();();()!());x];
    sum st 2};

/
x: ("mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X";
    "mem[8] = 11";
    "mem[7] = 101";
    "mem[8] = 0");
x2:("mask = 000000000000000000000000000000X1001X";
    "mem[42] = 100";
    "mask = 00000000000000000000000000000000X0XX";
    "mem[26] = 1");

d14p1 x //165
//d14p2 x
d14p2 x2    //208

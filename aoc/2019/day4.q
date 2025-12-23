d4:{[a;b]
    ns:string a+til 1+b-a;
    ns:ns where ns~'asc each ns;
    ns:count each/:group each ns;
    ns};
d4p1:{[a;b]sum 1<max each d4[a;b]};
d4p2:{[a;b]sum 2 in/:d4[a;b]};

/
No input file, the input is two integers.

d4p1[108457;562041] //2779i
d4p2[108457;562041] //1972i

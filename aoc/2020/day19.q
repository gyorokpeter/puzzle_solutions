.d19.gen:{[r0;rules]
    if[0=count rules; :enlist ""];
    m:r0[first rules];
    $[m`t;m[`r],/:.d19.gen[r0;1_rules];
        raze .d19.gen[r0] each (m[`r],\:1_rules)]};
d19:{p:"\n\n"vs"\n"sv x;
    a:": "vs/:"\n"vs p[0];
    num:"J"$a[;0];
    t:"\""in/:a[;1];
    r:1_?[0b,t;(::),a[;1;1];(::),"J"$" "vs/:/:" | "vs/:a[;1]];
    r0:([num]t;r);
    str:"\n"vs p 1;
    (r0;str)};
d19p1:{
    p:d19 x;r0:p 0;str:p 1;
    found:.d19.gen[r0;enlist 0];
    sum str in found};
d19p2:{
    p:d19 x;r0:p 0;str:p 1;
    found42:.d19.gen[r0;enlist 42];
    found31:.d19.gen[r0;enlist 31];
    if[0<count found42 inter found31; '"unsupported input"];
    if[1<count distinct count each found42,found31; '"unsupported input"];
    bits:count[found42 0] cut/:str;
    pre:(bits in found42)?\:0b;
    post:{x:deltas reverse x;$[0=first x;0;x?-1]}each bits in found31;
    sum(0<post) and (pre>post) and (pre+post)=count each bits};

/
x:"\n"vs"0: 4 1 5\n1: 2 3 | 3 2\n2: 4 4 | 5 5\n3: 4 5 | 5 4\n4: \"a\"\n5: \"b\"\n\nababbb\nbababa";
x,:"\n"vs"abbbab\naaabbb\naaaabbb";

x2:"\n"vs"42: 9 14 | 10 1\n9: 14 27 | 1 26\n10: 23 14 | 28 1\n1: \"a\"\n11: 42 31\n5: 1 14 | 15 1";
x2,:"\n"vs"19: 14 1 | 14 14\n12: 24 14 | 19 1\n16: 15 1 | 14 14\n31: 14 17 | 1 13";
x2,:"\n"vs"6: 14 14 | 1 14\n2: 1 24 | 14 4\n0: 8 11\n13: 14 3 | 1 12\n15: 1 | 14\n17: 14 2 | 1 7";
x2,:"\n"vs"23: 25 1 | 22 14\n28: 16 1\n4: 1 1\n20: 14 14 | 1 15\n3: 5 14 | 16 1\n27: 1 6 | 14 18";
x2,:"\n"vs"14: \"b\"\n21: 14 1 | 1 14\n25: 1 1 | 1 14\n22: 14 14\n8: 42\n26: 14 22 | 1 20";
x2,:"\n"vs"18: 15 15\n7: 14 5 | 1 21\n24: 14 1\n";
x2,:enlist"abbbbbabbbaaaababbaabbbbabababbbabbbbbbabaaaa";
x2,:enlist"bbabbbbaabaabba";
x2,:enlist"babbbbaabbbbbabbbbbbaabaaabaaa";
x2,:enlist"aaabbbbbbaaaabaababaabababbabaaabbababababaaa";
x2,:enlist"bbbbbbbaaaabbbbaaabbabaaa";
x2,:enlist"bbbababbbbaaaaaaaabbababaaababaabab";
x2,:enlist"ababaaaaaabaaab";
x2,:enlist"ababaaaaabbbaba";
x2,:enlist"baabbaaaabbaaaababbaababb";
x2,:enlist"abbbbabbbbaaaababbbbbbaaaababb";
x2,:enlist"aaaaabbaabaaaaababaa";
x2,:enlist"aaaabbaaaabbaaa";
x2,:enlist"aaaabbaabbaaaaaaabbbabbbaaabbaabaaa";
x2,:enlist"babaaabbbaaabaababbaabababaaab";
x2,:enlist"aabbbbbaabbbaaaaaabbbbbababaaaaabbaaabba";

d19p1 x //2
//d19p2 x
d19p2 x2    //12

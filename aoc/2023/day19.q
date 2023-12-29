d19p1:{ra:"\n"vs/:"\n\n"vs"\n"sv x;
    rulep:"{"vs/:-1_/:ra 0;
    rule:(`$rulep[;0])!value each"{$[",/:(";"sv/:{$[":"in x;[p:":"vs x;
        if[not all p[1]in .Q.A,.Q.a;'`nyi];p2:(op:$["<"in p 0;"<";">"])vs p 0;
        if[not 1=count p2 0;'`nyi];s:`$p2 0;if[not s in`x`m`a`s;'`nyi];
        n:"J"$p2 1;if[null n;'`nyi];"x[`",string[s],"]",op,string[n],";`",p 1];
        [if[not all x in .Q.A,.Q.a;'`nyi];"`",x]]}each/:","vs/:rulep[;1]),\:"]}";
    ap:"="vs/:/:","vs/:1_/:-1_/:ra 1;
    att:(`$ap[;;0])!'"J"$ap[;;1];
    acc:{{$[z in`A`R;z;x[z][y]]}[x;y]/[`in]}[rule]each att;
    sum sum att where acc=`A};
d19p2:{rulep:"{"vs/:-1_/:first"\n"vs/:"\n\n"vs"\n"sv x;
    rule:(`$rulep[;0])!{$[":"in x;[p:":"vs x;op:$["<"in p 0;"<";">"];
        p2:op vs p 0;(`$p2 0;op;"J"$p2 1;`$p 1)];`$x]}each/:","vs/:rulep[;1];
    split:{[rule;x]
        x[`live]:1b;
        r:rule x`node;
        split1:{[x;rs]
            if[98=type x;:raze .z.s[;rs]each x];
            if[not x`live;:enlist x];
            if[1=count rs; :enlist@[x;`node`live;:;(rs;0b)]];
            fld:rs 0; op:rs 1; num:rs 2; tgt:rs 3;
            lon:`$string[fld],"0";hin:`$string[fld],"1";
            $[op="<";
                $[x[lon]>=num; enlist x;
                  x[hin]<num; enlist @[x;`node`live;:;(tgt;0b)];
                  (@[x;hin,`node`live;:;(num-1;tgt;0b)];@[x;lon;:;num])
                ];
                $[x[hin]<=num; enlist x;
                  x[lon]>num; enlist @[x;`node`live;:;(tgt;0b)];
                  (@[x;lon,`node`live;:;(num+1;tgt;0b)];@[x;hin;:;num])
                ]
            ]};
        res:split1/[x;r];
        delete live from res};
    total:0;
    queue:enlist`x0`x1`m0`m1`a0`a1`s0`s1`node!(8#1 4000),`in;
    while[count queue;
        nxts:raze split[rule]each queue;
        total+:exec sum (1+x1-x0)*(1+m1-m0)*(1+a1-a0)*(1+s1-s0) from nxts where node=`A;
        queue:delete from nxts where node in`A`R;
    ];
    total};


/
x:"\n"vs"px{a<2006:qkq,m>2090:A,rfg}\npv{a>1716:R,A}\nlnx{m>1548:A,A}\nrfg{s<537:gd,x>2440:R,A}";
x,:"\n"vs"qs{s>3448:A,lnx}\nqkq{x<1416:A,crn}\ncrn{x>2662:A,R}\nin{s<1351:px,qqz}\nqqz{s>2770:qs,m<1801:hdj,R}";
x,:"\n"vs"gd{a>3333:R,R}\nhdj{m>838:A,pv}\n\n{x=787,m=2655,a=1222,s=2876}\n{x=1679,m=44,a=2067,s=496}";
x,:"\n"vs"{x=2036,m=264,a=79,s=2244}\n{x=2461,m=1339,a=466,s=291}\n{x=2127,m=1623,a=2188,s=1013}";

d19p1 x //19114
d19p2 x //167409079868000

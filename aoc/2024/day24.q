.d24.run:{[val;gate]
    while[count missing:(exec goal from gate) except key val;
        nxts:select from gate where goal in missing;
        nxts:select from nxts where in1 in key val, in2 in key val;
        val,:exec goal!.'[op;val[in1],'val in2] from nxts;
    ];
    val{desc x where x like "z*"}key[val]};
d24p1:{a:"\n\n"vs"\n"sv x;
    b:": "vs/:"\n"vs a 0;
    val:(`$b[;0])!"B"$b[;1];
    c:" "vs/:"\n"vs a 1;
    gate:([goal:`$c[;4]]in1:`$c[;0];in2:`$c[;2];op:(("AND";"OR";"XOR")!(and;or;<>))c[;1]);
    2 sv .d24.run[val;gate]};
.d24.swap:{[gate;lbl]   //for experimenting
    gate[([]goal:lbl)]:reverse gate[([]goal:lbl)];
    gate};
.d24.renderGates:{[gate]
    es1:exec(string[in1],'" -> g",/:string i) from gate;
    es2:exec(string[in2],'" -> g",/:string i) from gate;
    es3:exec("g",/:string[i],'" -> ",/:string goal) from gate;
    es:raze"    ",/:(es1,es2,es3),\:"\n";
    ns:raze"    ",/:(exec ("g",/:string[i],'" [label=\"",/:string[opn],\:"\"]") from gate),\:"\n";
    "digraph G {\n",es,ns,"}"};
d24p2:{a:"\n\n"vs"\n"sv x;
    b:": "vs/:"\n"vs a 0;
    val:(`$b[;0])!"B"$b[;1];
    c:" "vs/:"\n"vs a 1;
    gate:([goal:`$c[;4]]in1:`$c[;0];in2:`$c[;2];opn:`$c[;1]);
    xin:{asc x where x like "x*"}key val;
    zin:{asc x where x like "z*"}exec goal from gate;
    outs:exec opn(;)'goal by inp from (select opn,inp:in1,goal from gate),select opn,inp:in2,goal from gate;
    xout:xin#outs;
    xxor:{(x@'where each value[x][;;0]=`XOR)[;0;1]}xout;
    xorout:outs value xxor;
    xorxor:1_key[xxor]!{(x@'where each x[;;0]=`XOR)[;;1]}xorout;
    zexp:1_-1_zin;
    badZ:select from ([]goal:zexp)#gate where opn<>`XOR;
    bad:xxor where not xorxor~'(1_key xxor)!enlist each zexp;
    badOuts:outs bad;
    allSwaps:();
    swapChild:where any each zexp in/:badOuts[;;1];
    allSwaps,:badOuts[swapChild;;1];
    swapSibling:where`OR in/:badOuts[;;0];
    allSwaps,:outs[gate[([]goal:bad swapSibling);`in1]][;;1];
    badZ2:exec goal!(in1,'in2) from badZ;
    swapGrandchild:raze{key[x],/:'value x}raze each bad,/:'/:badZ2 inter/:\:badOuts[;;1];
    allSwaps,:swapGrandchild[;0],'outs[swapGrandchild[;1];;1]except'swapGrandchild[;2];
    swapChildWithSibling:where{(count each x)>count each distinct each x}outs badOuts[;;1];
    t:{(x where`XOR=x[;0])[;1]}each badOuts swapChildWithSibling;
    allSwaps,:t,'outs[gate[([]goal:bad swapChildWithSibling);`in1];;1]except'bad swapChildWithSibling;
    ","sv string asc raze allSwaps};

/

x:"\n"vs"x00: 1\nx01: 0\nx02: 1\nx03: 1\nx04: 0\ny00: 1\ny01: 1\ny02: 1\ny03: 1\ny04: 1\n";
x,:"\n"vs"ntg XOR fgs -> mjb\ny02 OR x01 -> tnw\nkwq OR kpj -> z05\nx00 OR x03 -> fst\ntgd XOR rvg -> z01";
x,:"\n"vs"vdt OR tnw -> bfw\nbfw AND frj -> z10\nffh OR nrd -> bqk\ny00 AND y03 -> djm\ny03 OR y00 -> psh";
x,:"\n"vs"bqk OR frj -> z08\ntnw OR fst -> frj\ngnj AND tgd -> z11\nbfw XOR mjb -> z00\nx03 OR x00 -> vdt";
x,:"\n"vs"gnj AND wpb -> z02\nx04 AND y00 -> kjc\ndjm OR pbm -> qhw\nnrd AND vdt -> hwm\nkjc AND fst -> rvg";
x,:"\n"vs"y04 OR y02 -> fgs\ny01 AND x02 -> pbm\nntg OR kjc -> kwq\npsh XOR fgs -> tgd\nqhw XOR tgd -> z09";
x,:"\n"vs"pbm OR djm -> kpj\nx03 XOR y03 -> ffh\nx00 XOR y04 -> ntg\nbfw OR bqk -> z06\nnrd XOR fgs -> wpb";
x,:"\n"vs"frj XOR qhw -> z04\nbqk OR frj -> z07\ny03 OR x01 -> nrd\nhwm AND bqk -> z03\ntgd XOR rvg -> z12";
x,:enlist"tnw OR pbm -> gnj";

d24p1 x //2024
//d24p2 x

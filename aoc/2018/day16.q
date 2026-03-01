//WTF these are still not built in in 2018?!
.q.bitand:{0b sv (0b vs x)and 0b vs y};
.q.bitor:{0b sv (0b vs x)or 0b vs y};

d16ins:()!();
d16ins[`addr]:{[op;reg]reg[op 3]:reg[op 1]+reg[op 2];reg};
d16ins[`addi]:{[op;reg]reg[op 3]:reg[op 1]+op 2;reg};
d16ins[`mulr]:{[op;reg]reg[op 3]:reg[op 1]*reg[op 2];reg};
d16ins[`muli]:{[op;reg]reg[op 3]:reg[op 1]*op 2;reg};
d16ins[`banr]:{[op;reg]reg[op 3]:reg[op 1] bitand reg[op 2];reg};
d16ins[`bani]:{[op;reg]reg[op 3]:reg[op 1] bitand op 2;reg};
d16ins[`borr]:{[op;reg]reg[op 3]:reg[op 1] bitor reg[op 2];reg};
d16ins[`bori]:{[op;reg]reg[op 3]:reg[op 1] bitor op 2;reg};
d16ins[`setr]:{[op;reg]reg[op 3]:reg[op 1];reg};
d16ins[`seti]:{[op;reg]reg[op 3]:op 1;reg};
d16ins[`gtir]:{[op;reg]reg[op 3]:`long$op[1]>reg[op 2];reg};
d16ins[`gtri]:{[op;reg]reg[op 3]:`long$reg[op 1]>op 2;reg};
d16ins[`gtrr]:{[op;reg]reg[op 3]:`long$reg[op 1]>reg[op 2];reg};
d16ins[`eqir]:{[op;reg]reg[op 3]:`long$op[1]=reg[op 2];reg};
d16ins[`eqri]:{[op;reg]reg[op 3]:`long$reg[op 1]=op 2;reg};
d16ins[`eqrr]:{[op;reg]reg[op 3]:`long$reg[op 1]=reg[op 2];reg};

d16match:{[ins;c;bf;af]
    paf:.[;(c;bf)]each ins#d16ins;
    where paf~\:af};

d16filt:{[poss;cba]
    ins:cba[0][0];
    match:d16match[poss ins;cba 0;cba 1;cba 2];
    poss[ins]:poss[ins]inter match;
    if[1=count poss[ins]; poss[til[16]except ins]:poss[til[16]except ins] except\:poss[ins][0]];
    poss};

d16:{
    split:first where 0=3 msum count each x;
    eff:4 cut -1_split#x;
    code:"J"$" "vs/:eff[;1];
    before:"J"$", "vs/:first each "]"vs/:last each"["vs/:eff[;0];
    after:"J"$", "vs/:first each "]"vs/:last each"["vs/:eff[;2];
    test:"J"$" "vs/:(1+split)_x;
    (code;before;after;test)};

d16p1:{
    cba:d16 x;code:cba 0;before:cba 1;after:cba 2;
    matches:d16match[key d16ins]'[code;before;after];
    sum 3<=count each matches};

d16p2:{
    cba:d16 x;code:cba 0;before:cba 1;after:cba 2;test:cba 3;
    poss:til[16]!16#enlist key d16ins;
    poss2:d16filt/[poss;(;;)'[code;before;after]];
    insmap:first each poss2;
    first {[insmap;r;c]d16ins[insmap c 0][c;r]}[insmap]/[0 0 0 0;test]};

/
No example input provided

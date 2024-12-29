# Breakdown

## Part 1
Example input:
```q
x:"\n"vs"x00: 1\nx01: 0\nx02: 1\nx03: 1\nx04: 0\ny00: 1\ny01: 1\ny02: 1\ny03: 1\ny04: 1\n";
x,:"\n"vs"ntg XOR fgs -> mjb\ny02 OR x01 -> tnw\nkwq OR kpj -> z05\nx00 OR x03 -> fst";
x,:"\n"vs"tgd XOR rvg -> z01\nvdt OR tnw -> bfw\nbfw AND frj -> z10\nffh OR nrd -> bqk";
x,:"\n"vs"y00 AND y03 -> djm\ny03 OR y00 -> psh\nbqk OR frj -> z08\ntnw OR fst -> frj";
x,:"\n"vs"gnj AND tgd -> z11\nbfw XOR mjb -> z00\nx03 OR x00 -> vdt\ngnj AND wpb -> z02";
x,:"\n"vs"x04 AND y00 -> kjc\ndjm OR pbm -> qhw\nnrd AND vdt -> hwm\nkjc AND fst -> rvg";
x,:"\n"vs"y04 OR y02 -> fgs\ny01 AND x02 -> pbm\nntg OR kjc -> kwq\npsh XOR fgs -> tgd";
x,:"\n"vs"qhw XOR tgd -> z09\npbm OR djm -> kpj\nx03 XOR y03 -> ffh\nx00 XOR y04 -> ntg";
x,:"\n"vs"bfw OR bqk -> z06\nnrd XOR fgs -> wpb\nfrj XOR qhw -> z04\nbqk OR frj -> z07";
x,:"\n"vs"y03 OR x01 -> nrd\nhwm AND bqk -> z03\ntgd XOR rvg -> z12\ntnw OR pbm -> gnj";
```

### Main
We split the input into groups:
```q
q)a
"x00: 1\nx01: 0\nx02: 1\nx03: 1\nx04: 0\ny00: 1\ny01: 1\ny02: 1\ny03: 1\ny04: 1"
"ntg XOR fgs -> mjb\ny02 OR x01 -> tnw\nkwq OR kpj -> z05\nx00 OR x03 -> fst\ntgd XOR rvg -> z01\.."
```
We split the first group on newlines and then on `": "`:
```q
q)b:": "vs/:"\n"vs a 0
q)b
"x00" ,"1"
"x01" ,"0"
"x02" ,"1"
"x03" ,"1"
"x04" ,"0"
"y00" ,"1"
"y01" ,"1"
"y02" ,"1"
"y03" ,"1"
"y04" ,"1"
```
We create a dictionary of initial values by casting the first elements into symbols and the second
elements into booleans:
```q
q)val:(`$b[;0])!"B"$b[;1]
q)val
x00| 1
x01| 0
x02| 1
x03| 1
x04| 0
y00| 1
y01| 1
y02| 1
y03| 1
y04| 1
```
We split the second group on newlines, then spaces:
```q
q)c:" "vs/:"\n"vs a 1
q)c
"ntg" "XOR" "fgs" "->" "mjb"
"y02" "OR"  "x01" "->" "tnw"
"kwq" "OR"  "kpj" "->" "z05"
"x00" "OR"  "x03" "->" "fst"
"tgd" "XOR" "rvg" "->" "z01"
..
```
We create a table of the gates by parsing the respective elements as symbols, and replacing the
operator names with the operators themselves (`<>` for XOR):
```q
q)gate:([goal:`$c[;4]]in1:`$c[;0];in2:`$c[;2];op:(("AND";"OR";"XOR")!(and;or;<>))c[;1]);
q)gate
goal| in1 in2 op
----| ----------
mjb | ntg fgs ~=
tnw | y02 x01 |
z05 | kwq kpj |
fst | x00 x03 |
z01 | tgd rvg ~=
...
```

### Running the circuit
This is the function `.d24.run` (I extracted it to reuse with part 2 but it turned out to be
unnecessary).

The function takes the `val` and `gate` parameters, which were created in the `d24p1` function.

We iterate as long as not all values corresponding to the gates are in the `val` dictionary:
```q
    while[count missing:(exec goal from gate) except key val;
        ...
    ];

q)missing:(exec goal from gate) except key val
q)missing
`mjb`tnw`z05`fst`z01`bfw`z10`bqk`djm`psh`z08`frj`z11`z00`vdt`z02`kjc`qhw`hwm`rvg`fgs`pbm`kwq`tgd`z..
```
During iteration, we find the gates corresponding to the missing values:
```q
q)nxts:select from gate where goal in missing
q)nxts
goal| in1 in2 op
----| ----------
mjb | ntg fgs ~=
tnw | y02 x01 |
z05 | kwq kpj |
fst | x00 x03 |
z01 | tgd rvg ~=
..
```
We filter to only those gates for which we know both inputs:
```q
q)nxts:select from nxts where in1 in key val, in2 in key val
q)nxts
goal| in1 in2 op
----| ----------
tnw | y02 x01 |
fst | x00 x03 |
djm | y00 y03 &
psh | y03 y00 |
vdt | x03 x00 |
kjc | x04 y00 &
fgs | y04 y02 |
pbm | y01 x02 &
ffh | x03 y03 ~=
ntg | x00 y04 ~=
nrd | y03 x01 |
```
We update the value dictionary by looking up the two inputs in the operands and applying the
operator between them:
```q
q)exec goal!.'[op;val[in1],'val in2] from nxts
tnw| 1
fst| 1
djm| 1
psh| 1
vdt| 1
kjc| 0
fgs| 1
pbm| 1
ffh| 0
ntg| 0
nrd| 1
q)val,:exec goal!.'[op;val[in1],'val in2] from nxts
q)val
x00| 1
x01| 0
x02| 1
x03| 1
x04| 0
y00| 1
y01| 1
y02| 1
y03| 1
y04| 1
tnw| 1
fst| 1
djm| 1
psh| 1
vdt| 1
..
```
At the end of the iteration, we filter to the keys starting with `"z"`. We sort the keys in
descending order such that the most significant bits are first:
```q
q){desc x where x like "z*"}key[val]
`z12`z11`z10`z09`z08`z07`z06`z05`z04`z03`z02`z01`z00
q)val{desc x where x like "z*"}key[val]
0011111101000b
```
We use the base conversion variant of `sv` to turn this into an integer:
```q
q)2 sv val{desc x where x like "z*"}key[val]
2024
```

## Part 2
I didn't solve this programmatically. Instead I experimented with rendering the circuit with
GraphViz and finding the discrepancies, then manually fixing them.

The following function can be used to create the `.dot` input for GraphViz:
```q
.d24.renderGates:{[gate]
    es1:exec(string[in1],'" -> g",/:string i) from gate;
    es2:exec(string[in2],'" -> g",/:string i) from gate;
    es3:exec("g",/:string[i],'" -> ",/:string goal) from gate;
    es:raze"    ",/:(es1,es2,es3),\:"\n";
    ns:raze"    ",/:(exec ("g",/:string[i],'" [label=\"",/:string[opn],\:"\"]") from gate),\:"\n";
    "digraph G {\n",es,ns,"}"};
```
The following function  can be used to swap two gates. The parameters are such that if calling the
function on the `gate` variable repeatedly with various parameters ends up with the correct circuit,
the parameters are exactly those that need to be put into the puzzle answer.
```q
.d24.swap:{[gate;lbl]
    gate[([]goal:lbl)]:reverse gate[([]goal:lbl)];
    gate};
```

# Whiteboxing

## Part 2

This is a programmatic way to find the swapped gates by pattern matching. I have only tested it on
my input, so the patterns might not work on other inputs.

We parse the input as in part 1, but instead of replacing the operators, we keep their names in an
`opn` column:
```q
    a:"\n\n"vs"\n"sv x;
    b:": "vs/:"\n"vs a 0;
    val:(`$b[;0])!"B"$b[;1];
    c:" "vs/:"\n"vs a 1;
    gate:([goal:`$c[;4]]in1:`$c[;0];in2:`$c[;2];opn:`$c[;1]);
```
We find the labels for the "x" and "z" values (we won't use the "y" labels):
```q
    xin:{asc x where x like "x*"}key val;
    zin:{asc x where x like "z*"}exec goal from gate;
```
We create a backwards mapping for the gates, so we can do lookups in both directions:
```q
    outs:exec opn(;)'goal by inp from (select opn,inp:in1,goal from gate),select opn,inp:in2,goal from gate;
```
The first pattern is that the "x" nodes must have an XOR gate connected to them. We look these up
for all "x" nodes:
```q
    xout:xin#outs;
    xxor:{(x@'where each value[x][;;0]=`XOR)[;0;1]}xout;
```
Then these XOR nodes (except the first one) must also have another XOR node as a successor:
```q
    xorout:outs value xxor;
    xorxor:1_key[xxor]!{(x@'where each x[;;0]=`XOR)[;;1]}xorout;
```
Another pattern is that the "z" nodes must be connected to XOR gates:
```q
    zexp:1_-1_zin;
    badZ:select from ([]goal:zexp)#gate where opn<>`XOR;
```
And these XOR gates must be connected to the second XOR gates that we found earlier:
```q
    bad:xxor where not xorxor~'(1_key xxor)!enlist each zexp;
    badOuts:outs bad;
```
With this info we can look up all four discrepancies and fix them.

The first error has the "z" node on the wrong gate instead of the XOR. We find this by looking for
gates where the XOR gate doesn't have a "z" output while its sibling does. These two are the ones we
need to swap.
```q
    allSwaps:();
    swapChild:where any each zexp in/:badOuts[;;1];
    allSwaps,:badOuts[swapChild;;1];
```
The second error has an OR gate attached to the first XOR. For this one we need to swap the XOR node
with its sibling.
```q
    swapSibling:where`OR in/:badOuts[;;0];
    allSwaps,:outs[gate[([]goal:bad swapSibling);`in1]][;;1];
```
The third error has two wrong gates between the XOR and the "z" node (in my case it's an AND and
OR). We can match this by taking the intersection of the "wrong XOR output" set with the "wrong z
input" set. From the node where they intersect, we have to swap its grandchild that is the "z" node
with its other child.
```q
    badZ2:exec goal!(in1,'in2) from badZ;
    swapGrandchild:raze{key[x],/:'value x}raze each bad,/:'/:badZ2 inter/:\:badOuts[;;1];
    allSwaps,:swapGrandchild[;0],'outs[swapGrandchild[;1];;1]except'swapGrandchild[;2];
```
The fourth error has the "z" node directly attached to the sibling of the first XOR gate. So we find
the XOR gate with the wrong children and swap the output of the XOR child with the sibling that
leads to to the "z" node:
```q
    swapChildWithSibling:where{(count each x)>count each distinct each x}outs badOuts[;;1];
    t:{(x where`XOR=x[;0])[;1]}each badOuts swapChildWithSibling;
    allSwaps,:t,'outs[gate[([]goal:bad swapChildWithSibling);`in1];;1]except'bad swapChildWithSibling;
```
The final step is razing the swaps to a single list, sorting it and joining it with commas.
```q
    ","sv string asc raze allSwaps
```

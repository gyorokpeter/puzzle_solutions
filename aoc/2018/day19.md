# Breakdown
Example input:
```q
q)md5"\n"sv x
0x8b69c39957f1d33e829df9acb5c88627
```

## Common
The VM implementation is in [chronal.q](chronal.q), and uses [GenArch](../utils/README.md#genarch).
Most of that file is irrelevant to the solution.

## Part 1
It is possible to run the VM directly, although it already takes a long time:
```q
q).chronal.run .chronal.new[x]
`halt
257
((`addi;2;16;2);(`seti;1;0;4);(`seti;1;5;5);(`mulr;4;5;1);(`eqrr;1;3;1);(`addr;1;2;2);(`addi;2;1;2..
1464 1 257 974 975 975
2
```
The answer is the first element of the register array (`1464` in this case).

## Part 2
Not feasible using a direct solution.

## Whiteboxing
The program calculates the sum of divisors of some integer using an inefficient algorithm. By
heuristic, the integer that is checked is the largest value in the registers when `ip=1`.

The common function `d19` takes the value to put into register 0 as an additional parameter. We use
the debug version of the VM invocation called `.chronal.runD`, which allows setting a breakpoint. We
set one on instruction 1 and run the VM until it is hit:
```q
q)a:0
q)st:.chronal.runD[.chronal.editRegister[.chronal.new[x];0;a];1b;enlist 1;0b]
q)st
`break
1
((`addi;2;16;2);(`seti;1;0;4);(`seti;1;5;5);(`mulr;4;5;1);(`eqrr;1;3;1);(`addr;1;2;2);(`addi;2;1;2..
0 138 1 974 0 0
2
```
We find the maximum register value:
```q
q)max .chronal.getRegisters[st]
974
```
We find the divisors of this number using the brute-force division check:
```q
q){x where 0=last[x] mod x}1+til max .chronal.getRegisters[st]
1 2 487 974
q)sum{x where 0=last[x] mod x}1+til max .chronal.getRegisters[st]
1464
```
The same method works for part 2 (by passing in `a=1`), but it will take longer since the number is
larger.
```q
q)a:1
q)st:.chronal.runD[.chronal.editRegister[.chronal.new[x];0;a];1b;enlist 1;0b]
q)st
`break
1
((`addi;2;16;2);(`seti;1;0;4);(`seti;1;5;5);(`mulr;4;5;1);(`eqrr;1;3;1);(`addr;1;2;2);(`addi;2;1;2..
0 10550400 1 10551374 0 0
2
q)max .chronal.getRegisters[st]
10551374
q){x where 0=last[x] mod x}1+til max .chronal.getRegisters[st]
1 2 443 886 11909 23818 5275687 10551374
q){sum x where 0=last[x] mod x}1+til max .chronal.getRegisters[st]
15864120
```

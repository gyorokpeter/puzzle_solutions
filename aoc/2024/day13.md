# Breakdown

Example input:
```q
x:();
x,:enlist"Button A: X+94, Y+34";
x,:enlist"Button B: X+22, Y+67";
x,:enlist"Prize: X=8400, Y=5400";
x,:enlist"";
x,:enlist"Button A: X+26, Y+66";
x,:enlist"Button B: X+67, Y+21";
x,:enlist"Prize: X=12748, Y=12176";
x,:enlist"";
x,:enlist"Button A: X+17, Y+86";
x,:enlist"Button B: X+84, Y+37";
x,:enlist"Prize: X=7870, Y=6450";
x,:enlist"";
x,:enlist"Button A: X+69, Y+23";
x,:enlist"Button B: X+27, Y+71";
x,:enlist"Prize: X=18641, Y=10279";
```

## Part 1
We remove some garbage characters to help with parsing:
```q
q)x except\:"XY+=,"
"Button A: 94 34"
"Button B: 22 67"
"Prize: 8400 5400"
""
..
```
We merge the lines, cut on double newline and cut into lines again:
```q
q)a:"\n"vs/:"\n\n"vs"\n"sv x except\:"XY+=,"
q)a
"Button A: 94 34" "Button B: 22 67" "Prize: 8400 5400"
"Button A: 26 66" "Button B: 67 21" "Prize: 12748 12176"
"Button A: 17 86" "Button B: 84 37" "Prize: 7870 6450"
"Button A: 69 23" "Button B: 27 71" "Prize: 18641 10279"
```
We split on spaces, drop 2 elements for the first 2 lines and 1 element for the last line of each
group, then convert into integers:
```q
q)b:"J"$2 2 1_'/:" "vs/:/:a
q)b
94   34     22   67     8400 5400
26    66    67    21    12748 12176
17   86     84   37     7870 6450
69    23    27    71    18641 10279
```
A brute-force approach for part 1 generates 100*100 pairs of coordinates, corresponding to the
number of presses of each of the A and B buttons, and checks of the target coordinates are found in
the generated ones. For the first group:
```q
q)aa:first b
q)aa
94   34
22   67
8400 5400
```
We multiply the X and Y movements with every integer from 1 to 100:
```q
q)(1+til 100)*\:/:aa 0 1
94   34   188  68   282  102  376  136  470  170  564  204  658  238  752  272  846  306  940  340..
22   67   44   134  66   201  88   268  110  335  132  402  154  469  176  536  198  603  220  670..
```
We add these numbers pairwise to get a matrix:
```q
q)coords:(+/:\:).(1+til 100)*\:/:aa 0 1
q)coords
116  101    138  168    160  235    182  302    204  369    226  436    248  503    270  570    29..
210  135    232  202    254  269    276  336    298  403    320  470    342  537    364  604    38..
304  169    326  236    348  303    370  370    392  437    414  504    436  571    458  638    48..
398  203    420  270    442  337    464  404    486  471    508  538    530  605    552  672    57..
..
```
We look for the target coordinates using the [2D search](../utils/patterns.md#2d-search) technique:
```q
q)press:1+raze til[100],/:'where each aa[2]~/:/:coords
q)press
80 40
```
We return the result using a conditional: if we found the coordinates, we sum them after
multiplying with 3 and 1 respectively, otherwise we return zero.
```q
q)$[count press;min sum each 3 1*/:press;0]
280
```
We call this function for each group and sum the results:
```q
q)f each b
280 0 200 0
q)sum f each b
480
```

## Part 2
The input parsing is similar, except we add the offset to the coordinates:
```q
q)a:"\n"vs/:"\n\n"vs"\n"sv x except\:"XY+=,"
q)b:0 0 10000000000000+/:"J"$2 2 1_'/:" "vs/:/:a
q)b
94             34             22             67             10000000008400 10000000005400
26             66             67             21             10000000012748 10000000012176
17             86             84             37             10000000007870 10000000006450
69             23             27             71             10000000018641 10000000010279
```
This time the solution is very boring. We have two equations in each group with two variales each,
so we can express one of the variables from the first equation, plug it into the second, calculae
the value of the second variable and then plug it back to the first one to calculate the first
variable as well. The following code is a mechanization of this process, but I will not explain it
as I came for the *programming* challenge, not for the *math* challenge. If you like math, you might
want to look at [Project Euler](https://projecteuler.net/) instead.
```q
q)px:((b[;2;0]*b[;1;1]%b[;1;0])-b[;2;1])%(b[;0;0]*b[;1;1]%b[;1;0])-b[;0;1];
q)py:(b[;2;0]-px*b[;0;0])%b[;1;0];
q)\P 17
q)px
81081081161.081085 118679050709 71266110727.916611 102851800151
q)py
108108108148.10809 103199174542 104624715779.70735 107526881786
```
By setting the float precision to 17 we can see that the solutions for the second and fourth group
are integets. We can perform this check by casting the values to `long` and then comparing them
to the float version. If they are equal, they are good solutions, otherwise they are not.
```q
q)px=`long$px
0101b
q)py=`long$py
0101b
q)?[(px=`long$px)and py=`long$py;py+3*px;0]
0 459236326669 0 416082282239f
q)sum?[(px=`long$px)and py=`long$py;py+3*px;0]
875318608908f
```
Note that there is no example given in the puzzle.

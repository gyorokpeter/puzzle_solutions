# Breakdown
Example input:
```q
x:"\n"vs"NNCB\n\nCH -> B\nHH -> N\nCB -> H\nNH -> C\nHB -> C\nHC -> B\nHN -> C\nNN -> C\nBH -> H"
x,:"\n"vs"NC -> B\nNB -> B\nBN -> B\nBB -> N\nBC -> B\nCC -> N\nCN -> C"
steps:10
```

## Common
The solution is the same for part 1 and 2, the only difference is the number of iterations.

The idea is to store the number of pairs of characters, which makes it easy to keep track of the
counts across generations.

We cut the input on `"\n\n"` to get the two sections. The first section is the initial string.

We cut the second section to lines, then cut each line on `" -> "` and form a dictionary.
```q
q)a:"\n\n"vs"\n"sv x
q)s:a 0
q)r:{x[;0]!raze x[;1]}" -> "vs/:"\n"vs a[1]
q)r
"CH"| B
"HH"| N
"CB"| H
...
```
We initialize the pair counter from the initial string. To do this we take substrings from all
positions (except the last) and keep the first two characters:
```q
q)til[count[s]-1]
0 1 2
q)til[count[s]-1]_\:s
"NNCB"
"NCB"
"CB"
q)2#/:til[count[s]-1]_\:s
"NN"
"NC"
"CB"
```
The frequency dictionary can be obtained using `count each group`:
```q
q)pair:count each group 2#/:til[count[s]-1]_\:s
q)pair
"NN"| 1
"NC"| 1
"CB"| 1
```
Next comes the actual iteration. The number of steps will be a parameter for the function.

In the first step, we take the dictionary apart and find what character will be inserted into each
pair:
```q
q)k:key pair; v:value pair; rk:r[k]
q)rk
"CBH"
```
We generate the new pairs as a table. The table will consist of two parts. In the first part, the
first column will be the first characters of each pair concatenated with the inserted characters,
and in the second part, it will be the inserted characters concatenated with the last characters of
each pair. The second column is the list of counts for the pairs in both parts.
```q
q)([]ch:(k[;0],'rk);n:v)
ch   n
------
"NC" 1
"NB" 1
"CH" 1
q)([]ch:(rk,'k[;1]);n:v)
ch   n
------
"CN" 1
"BC" 1
"HB" 1
q)npair:([]ch:(k[;0],'rk),(rk,'k[;1]);n:v,v)
q)npair
ch   n
------
"NC" 1
"NB" 1
"CH" 1
"CN" 1
"BC" 1
"HB" 1
```
We collapse this into a dictionary again by summing the counts by the pairs:
```q
q)pair:exec sum n by ch from npair
q)pair
"BC"| 1
"CH"| 1
"CN"| 1
"HB"| 1
"NB"| 1
"NC"| 1
```
After all the steps are done, we will end up with the final counts for each pair:
```q
q)pair
"BB"| 812
"BC"| 120
"BH"| 81
"BN"| 735
"CB"| 115
...
```
We now need to turn this back into a count for the individual characters. If we take the first
character of each pair and match it to the count for the pair, and then do the same for the last
character of each pair, we counted every character twice with the exception of the first and last
character in the string, since those only occur in one pair instead of two. After compensating for
this we divide the counts of the characters by two.

We find the count of each character in the first position:
```q
q)chr0:([]ch:key[pair][;0]; n:value pair)
q)chr0
ch n
------
B  812
B  120
B  81
B  735
C  115
...
```
We do the same for the second position:
```q
q)chr1:([]ch:key[pair][;1]; n:value pair)
q)chr1
ch n
------
B  812
C  120
H  81
N  735
...
```
We also add a count of 1 for the character at the beginning and the end of the original string:
```q
q)chr2:([]ch:first[s],last s;n:1)
q)chr2
ch n
----
N  1
B  1
```
Finally we sum together all these counts by character and divide the results by 2:
```q
q)chr:exec sum[n]div 2 by ch from chr0,chr1,chr2
q)chr
B| 1749
C| 298
H| 161
N| 865
```
To get the answer we subtract the minimum of this dictionary from the maximum.
```q
q){max[x]-min x}asc chr
1588
```

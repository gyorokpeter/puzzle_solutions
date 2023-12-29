# Breakdown

Example input:
```q
x:"\n"vs"32T3K 765\nT55J5 684\nKK677 28\nKTJJT 220\nQQQJA 483";
```

## Common
To help with ranking hands, we declare an ordering of hand strength based on the number of copies of each rank in the hand:
```q
.d7.hts:(1 1 1 1 1;2 1 1 1;2 2 1;3 1 1;3 2;4 1;enlist 5);
```
So the lowest hand is high card which has 5 different ranks with 1 copy each (so `1 1 1 1 1`), and the highest is five of a kind which has 5 copies of 1 rank (so `enlist 5`, note that it still needs to be a list).

## Part 1
We convert the card ranks to their actual ranking in sequence, which is `"23456789TJQKA"` for part 1. We also extract the scores.
```q
q)a:" "vs/:x
q)hand:"23456789TJQKA"?a[;0]
q)hand
1  0  8  1 11
8  3  3  9 3
11 11 4  5 5
11 8  9  9 8
10 10 10 9 12
q)sc:"J"$a[;1]
q)sc
765 684 28 220 483
```
We need to count the frequency of each rank in the hands. The [`group`](https://code.kx.com/q/ref/group/) function comes in handy as it groups the identical elements together so we can count them. Then we put the frequencies in descending order and drop the dictinary keys that were added by `group`, so the result is a list of frequencies that can be looked up directly in `.d7.hts`:
```q
q){group x}each hand
1 0 8 11!(0 3;,1;,2;,4)
8 3 9!(,0;1 2 4;,3)
11 4 5!(0 1;,2;3 4)
11 8 9!(,0;1 4;2 3)
10 9 12!(0 1 2;,3;,4)
q){count each group x}each hand
1 0 8 11!2 1 1 1
8 3 9!1 3 1
11 4 5!2 1 2
11 8 9!1 2 2
10 9 12!3 1 1
q){desc count each group x}each hand
1 0 8 11!2 1 1 1
3 8 9!3 1 1
11 5 4!2 2 1
8 9 11!2 2 1
10 9 12!3 1 1
q){value desc count each group x}each hand
2 1 1 1
3 1 1
2 2 1
2 2 1
3 1 1
q)ht:.d7.hts?{value desc count each group x}each hand
q)ht
1 3 2 2 3
```
To order the score by hand strength, we put the hand types and ranks into a temporary table so we can use `xdesc` on it:
```q
q)([]hand;ht;sc)
hand          ht sc
--------------------
1  0  8  1 11 1  765
8  3  3  9 3  3  684
11 11 4  5 5  2  28
11 8  9  9 8  2  220
10 10 10 9 12 3  483
q)`ht`hand xdesc ([]hand;ht;sc)
hand          ht sc
--------------------
10 10 10 9 12 3  483
8  3  3  9 3  3  684
11 11 4  5 5  2  28
11 8  9  9 8  2  220
1  0  8  1 11 1  765
```
We need to multiply the score with the reversed row index, which we can calculate as `count[i]-i`, using the implicit `i` row index of the table:
```q
q)exec count[i]-i from`ht`hand xdesc ([]hand;ht;sc)
5 4 3 2 1
q)exec sc*count[i]-i from`ht`hand xdesc ([]hand;ht;sc)
2415 2736 84 440 765
q)sum exec sc*count[i]-i from`ht`hand xdesc ([]hand;ht;sc)
6440
```

## Part 2
The input parsing is similar but the ranks have now changed to `"J23456789TQKA"`:
```q
a:" "vs/:x; hand:"J23456789TQKA"?a[;0]; sc:"J"$a[;1]
q)hand
2  1  9  2 11
9  4  4  0 4
11 11 5  6 6
11 9  0  0 9
10 10 10 0 12
q)sc
765 684 28 220 483
```
The hand type detection is a bit more complicated due to the presence of jokers. The idea is that we first remove the jokers (`except\:0`), then calculate the rank frequencies in the remaining hand, then increment the first frequency (the rank with the highest copies in the hand) by the number of missing cards. The hand with all jokers needs special handling because for that one there would be no first element to increment.
```q
ht:.d7.hts?{a:$[count x;value desc count each group x;enlist 0];
    a[0]+:5-count x;a}each hand except\:0;
q)ht
1 5 2 5 5
```
The rest of the logic is the same as for part 1.
```q
q)sum exec sc*count[i]-i from`ht`hand xdesc ([]hand;ht;sc)
5905
```

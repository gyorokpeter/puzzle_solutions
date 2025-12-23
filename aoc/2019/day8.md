# Breakdown

## Part 1
Example input:
```q
w:3
h:2
img:enlist"123456789012"
```
First we convert each character to a number. Note that this requires using `/:` (each-right)
because `"J"$` would normally try to parse the entire string as a single number.
```q
q)"J"$/:raze img
1 2 3 4 5 6 7 8 9 0 1 2
```
We then cut it into sublists each containing a layer. The size of a layer is `w*h`.
```q
q)layers:(w*h) cut "J"$/:raze img
q)layers
1 2 3 4 5 6
7 8 9 0 1 2
..
```
To find the layers with the least zeros, we first compare every number in this matrix with 0. In q
this is just that simple.
```q
q)0=layers
000000b
000100b
```
Then we sum each row to get the number of zeros in the layer.
```q
q)sum each 0=layers
0 1i
```
Using `{where x=min x}` (wrapped in a function due to the two usages of the same expression which
would either have to be written out twice or assigned to a temporary variable) we find which
layer(s) have the minimum number of zeros:
```q
q){where x=min x}sum each 0=layers
,0
```
We assume there will be exactly one matching layer so we take the first element:
```q
q)minz:first{where x=min x}sum each 0=layers
q)minz
0
```
We then compare the chosen layer to 1 and 2, sum each result and multiply the two:
```q
q){sum[x=1]*sum[x=2]}layers[minz]
1i
```

## Part 2
Example input:
```q
w:2
h:2
img:enlist"0222112222120000"
```
After converting the numbers to strings, we immediately index the list 0 1 with it. The net effect
is that 2's are replaced with nulls.
```q
q)0 1"J"$/:raze img
0 0N 0N 0N 1 1 0N 0N 0N 0N 1 0N 0 0 0 0
```
The reason this works is because in q every object can be used as an index as long as the "leaf"
elements are of a type that can index the target (the list 0 1 here). Each index will be replaced by
the corresponding value, therefore each 0 will become a 0 and each 1 will become a 1, and each 2
will become null because that's indexing out of bounds of the list.

Then we cut the input into layers. Note that in this matrix pretty-print the nulls are not printed.
```q
q)(w*h) cut 0 1"J"$/:raze img
0
1 1
    1
0 0 0 0
```
We reverse the list of layers, the reason for which will be apparent very soon:
```q
q)reverse(w*h) cut 0 1"J"$/:raze img
0 0 0 0
    1
1 1
0
```
Then we use the main trick for this day: the [`^` (fill)](https://code.kx.com/q/ref/fill/) operator.
What this does on the surface is very simple: it returns its right argument unless it is null,
otherwise it returns the left argument. The power of this comes from the fact that it works on
lists, so if we have two lists with some nulls, it will "paint" the list on the right over the list
on the left, with any nulls being "transparent". But this only works on two lists, and we have many.
However we can make use of the `/` (over) iterator. Just like it does summation when used with `+`,
it performs the painting between consecutive layers with `^`. So if we use `(^/)` on the list of
layers, we get exactly what the puzzle asks us to do. The only caveat is that with `(^/)` the top
layer should be last, since that gets painted over the partial results. Since in the input the top
layer comes first, we had to reverse the order of the layers.
```q
q)(^/)reverse(w*h) cut 0 1"J"$/:raze img
0 1 1 0
```
Now we only have one layer, we can cut it again, now on width only.
```q
q)w cut (^/)reverse(w*h) cut 0 1"J"$/:raze img
0 1
1 0
```
*The following part no longer applies to the example input.*
```q
q)w:25
q)h:6
q)img:x
q)md5 raze img
0x14c4ab42d1ea9740c2d0ff13f61ee27d
```
Because the inputs are copyrighted, I cannot include them in this breakdown.
```q
q)w cut (^/)reverse(w*h) cut 0 1"J"$/:raze img
0 1 1 0 0 0 1 1 0 0 1 0 0 1 0 1 1 1 0 0 1 1 1 1 0
1 0 0 1 0 1 0 0 1 0 1 0 1 0 0 1 0 0 1 0 0 0 0 1 0
1 0 0 1 0 1 0 0 0 0 1 1 0 0 0 1 0 0 1 0 0 0 1 0 0
1 1 1 1 0 1 0 0 0 0 1 0 1 0 0 1 1 1 0 0 0 1 0 0 0
1 0 0 1 0 1 0 0 1 0 1 0 1 0 0 1 0 0 0 0 1 0 0 0 0
1 0 0 1 0 0 1 1 0 0 1 0 0 1 0 1 0 0 0 0 1 1 1 1 0
```
I prefer to map this to an empty and a non-empty character to make it more readable.
```q
q)img2:" *"w cut (^/)reverse(w*h) cut 0 1"J"$/:raze img
q)img2
" **   **  *  * ***  **** "
"*  * *  * * *  *  *    * "
"*  * *    **   *  *   *  "
"**** *    * *  ***   *   "
"*  * *  * * *  *    *    "
"*  *  **  *  * *    **** "
```
Many people will stop here and say that the answer is "ACKPZ". However that is cheating as it is
using human brain power as a CAPTCHA recognizer. My solution goes all the way and reconstructs the
ASCII string that should be given as the puzzle answer. To do this, first we need to convert the
image into a list of letters. Right now each row is a scanline in the image. Since each character
is 5 pixels wide, if we cut the lines by 5 we get the components of each letter:
```q
q)5 cut/:img2
" **  " " **  " "*  * " "***  " "**** "
"*  * " "*  * " "* *  " "*  * " "   * "
"*  * " "*    " "**   " "*  * " "  *  "
"**** " "*    " "* *  " "***  " " *   "
"*  * " "*  * " "* *  " "*    " "*    "
"*  * " " **  " "*  * " "*    " "**** "
```
However, the coordinates are in the wrong order. Luckily a flip will fix that:
```q
q)flip 5 cut/:img2
" **  " "*  * " "*  * " "**** " "*  * " "*  * "
" **  " "*  * " "*    " "*    " "*  * " " **  "
"*  * " "* *  " "**   " "* *  " "* *  " "*  * "
"***  " "*  * " "*  * " "***  " "*    " "*    "
"**** " "   * " "  *  " " *   " "*    " "**** "
```
To make lookup easier, we join back each letter into a single string:
```q
q)raze each flip 5 cut/:img2
" **  *  * *  * **** *  * *  * "
" **  *  * *    *    *  *  **  "
"*  * * *  **   * *  * *  *  * "
"***  *  * *  * ***  *    *    "
"****    *   *   *   *    **** "
```
It is hard to see now, but each row is the flattened version of a letter. The `ocr` map at the
beginning of [day8.q](day8.q) contains a mapping from these flattened letter forms to the
corresponding ASCII character. All we have to do now is index into it.
```q
q)ocr raze each flip 5 cut/:img2
"ACKPZ"
```
However the task is underspecified if we want to do this. The letterforms are not
given, so the only way to find them is to manually try different inputs and compile
a list.

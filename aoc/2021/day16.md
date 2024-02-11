# Breakdown
Example inputs:
```q
x:"8A004A801A8002F478"
x:"620080001611562C8802118E34"
x:"C0015000016115A2E0802F182340"
x:"A0016C880162017C3686B18A3D4780"

x:"C200B40A82"
x:"04005AC33890"
x:"880086C3E88112"
x:"CE00C43D881120"
x:"D8005AC2A8F0"
x:"F600BC2D8F"
x:"9C005AC2F8F0"
x:"9C0141080250320F1802104A08"
```

## Common
The solution uses a recursive function (`prs`) that takes the input and
the current cursor position and returns a list of (sum version;evaluation result;pos).

We parse the input using `"X"$`, which casts into the byte type and is the only parsing method
that expects the input to be in hexadecimal. Then we split the bytes into bits and raze them to
get a single bit stream.
```q
q)x:"8A004A801A8002F478"
q)a:raze 0b vs/:"X"$2 cut x,$[1=count[x] mod 2;"0";""];
q)a
100010100000000001001010100000000001101010000000000000101111010001111000b
```
The `prs` function takes this bit sequence and a position.

We start by parsing the version and version and type by indexing into the stream and converting
back to bytes. Note that `0b sv` only works on lists of length 8, 16, 32 or 64, so we have to
left-pad the 3-bit values with zero bits:
```q
    p:p0;
    ver:0b sv 00000b,a[p+til 3];
    tp:0b sv 00000b,a[(p+3)+til 3];
```
We advance the current position past the header:
```q
    p+:6;
```
If the type is 4, we parse a literal number:
```q
    if[tp=4;
        ...
    ];
```
* We start by pulling the 4 bits of the value, skipping past the continuation marker:
```q
    r:a[1+p+til 4];
```
* While the continuation marker is true, we advance the current position and append 4 more digits:
```q
    while[a[p]; p+:5; r,:4#(p+1)_a];
```
* We also advance the position by 5 (since we have been doing a lookahead until now):
```q
    p+:5;
```
* We return the result that consists of the version, the parsed integer (using `2 sv` to convert
  to an integer) and the final position:
```q
    :(ver;2 sv r;p);
```
We fetch the length type bit and initialize a version sum and argument list variable:
```q
    i:a[p];
    vsum:ver;
    args:`int$();
```
If the length type is 0:
```q
    if[i=0;
        ...
    ];
```
* We fetch the 15 bits to get the length and advance the current position:
```q
    len:2 sv 15#(p+1)_a;
    p+:16;
```
* We calculate the end position for this packet:
```q
    end:p+len;
```
* We process packages until the position reaches the end:
```q
    while[p<end;
        ...
    ];
```
  * We call the function recursively using the current position:
```q
    v:.z.s[a;p];
```
  * We add the version sum from the result to the running total:
```q
    vsum+:v 0;
```
  * We also append the parsed argument to the argument list:
```q
    args,:v 1;
```
  * Finally we advance the position:
```q
    p:last v;
```
If the length type is 1:
```q
    if[i=1;
        ...
    ];
```
* We fetch the 11 bits to get the length and advance the current position:
```q
    cnt:2 sv 11#(p+1)_a;
    p+:12;
```
* We process the indicated 
```q
    do[cnt;
        ...
    ];
```
* The body of this loop is exactly the same as the `i=0` case.
```q
    v:.z.s[a;p];
    vsum+:v 0;
    args,:v 1;
    p:last v;
```
Now we can invoke the operator. If the operation is between 0 and 3, we index into the list `(sum;prd;min;max)`
to get the operation and apply it to the entire `args` list as its single argument:
```q
    res:$[tp within 0 3;(sum;prd;min;max)[tp][args];
    ...
```
If the operator is between 5 and 7, we subtract 5 from the operator so it becomes and index between 0 and 2,
we index into the list `(>;<;=)` and apply it to `args` as its argument list (this only works if `args` has
exactly 2 elements):
```q
    ...
    tp within 5 7;(>;<;=)[tp-5] . args;
    ...
```
Otherwise we throw an error:
```q
    ...
    '"invalid op ",string[`int$tp]];
```
We return the cumulative version sum, the result of applying the operator and the final position:
```q
    (vsum;res;p)
```
The answer is obtained by calling `prs` on the entire input. We are only interested in the version sum for part 1
and the operation result for part 2.
```q
    prs[a;0]
```

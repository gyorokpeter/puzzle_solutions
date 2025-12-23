# Breakdown
Example input:
```q
q)md5 raze x
0xd5787c727053c919132f04dc2c842a12
```
Because the inputs are copyrighted, I cannot include them in this breakdown.

This is just a straight-up simulation. It turns out that the exact timing between nodes doesn't
matter, in particular if multiple messages are sent to the same node it is OK to let them run until
they are out of input again.

## Part 1
We initialize the intcode interpreter:
```q
q)a:.intcode.new x
```
We create 50 copies, feeding a different number into each, then run them until they break:
```q
q)pcs:.intcode.runI[a]each enlist each til 50
```
We perform an iteration that has no fixed end point, there is an exit in the middle when we find the
answer:
```q
    while[1b;
        ...
    ];
```
In the iteration, we first extract the messages from the intcode VM outputs:
```q
q)msg:`id xasc flip`id`x`y!flip 3 cut raze pcs[;6]
q)msg
id x y
------
```
We check if there is a message with an `id` of 255, and if so, we return the `y` value from it:
```q
    if[255 in exec id from msg; :exec first y from msg where id=255];
```
We group the messages by ID:
```q
q)msg2:select xy:(x,'y) by id from msg
q)msg2
id| xy
--| --
```
We find which out of the 50 IDs are missing from the list:
```q
q)missing:til[50] except exec id from msg2
q)missing
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 ..
```
We append the `-1` messages for the missing IDs:
```q
q)msg2[([]id:missing)]:([]xy:count[missing]#enlist enlist -1)
q)msg2
id| xy
--| --
0 | -1
1 | -1
2 | -1
3 | -1
4 | -1
..
```
We extract all the messages in ascending ID order:
```q
q)msg3:raze each msg2[([]id:til 50);`xy]
q)msg3
-1
-1
-1
-1
..
```
We pass in the messages as inputs and resume simulation of the intcode VMs:
```q
q)pcs:.intcode.runI'[pcs;msg3]
```
The code of the iteration ends here.

Eventually we find that the ID 255 is in the messages:
```q
q)msg
id  x     y
---------------
255 16979 26163
```
We return the first `y` value:
```q
q)exec first y from msg where id=255
26163
```

## Part 2
In the initialization, we create two new variables, one for the contents of the NAT which is
normally a two-element list but is initialized to `::` to indicate nothing present, and the other is
the list of y-values sent by the NAT.
```q
q)a:.intcode.new x
q)pcs:.intcode.runI[a]each enlist each til 50
q)nat:(::)
q)nh:()
```
We do an "infinite" iteration again:
```q
    while[1b;
        ...
    ];
```
In the iteration, we first extract the messages from the intcode VM outputs:
```q
q)msg:`id xasc flip`id`x`y!flip 3 cut raze pcs[;6]
q)msg
id x y
------
```
We check if there is a message with an `id` of 255, and if so, we store the last such message in the
`nat` variable:
```q
    if[255 in exec id from msg; nat:exec (last x;last y) from msg where id=255];
```
We fill in the missing messages with -1's as in part 1:
```q
q)msg2:select xy:(x,'y) by id from msg
q)missing:til[50] except exec id from msg2
q)msg2[([]id:missing)]:([]xy:count[missing]#enlist enlist -1)
q)msg3:raze each msg2[([]id:til 50);`xy]
```
This time, if all 50 IDs are missing AND there is something in the NAT (which is not the case the
first time the all-missing scenario occurs), we perform some special actions:
```q
    if[(50=count missing) and not nat~(::);
        ...
    ];
```
These actions include overwriting the message to node 0 with the NAT content, appending the last
y-value in the NAT to the `nh` variable, and checking if the last two `nh` values are equal, in
which case we return that value.
```q
    msg3[0]:nat;
    nh,:last nat;
    if[(1<count nh) and 1=count distinct -2#nh; :last nh];
```
Finally, we pass in the messages as inputs and resume simulation of the intcode VMs:
```q
q)pcs:.intcode.runI'[pcs;msg3]
```
The code of the iteration ends here.

Eventually we end up with the last two `nh` values being the same:
```q
q)nh
26163 24344 22837 21674 20817 20200 19763 19455 19238 19086 18980 18905 18853 18817 18791 18773 18..
q)-2#nh
18733 18733
```

## Whiteboxing
The first input (address) is an index into a jump table. The code at the targets of the jump table
initializes the following variables in a different way, but from there each instance operates the
same way:
1. Address multiplier
2. Data buffer size
3. Data buffer address
4. Pointer to data processing function
5. Destination list size
6. Destination list address

For the data buffer size and destination list size, the unit is two integers, but the meaning of the
elements in the list itself is different. In the data buffer, the first integer indicates whether
the cell is full (1) or empty (0). The second is the content of the cell. In the destination list,
the first integer is the destination address and the second integer is the data X value (a.k.a.
multiplied address).

The data processing function can be one of the following:
- Get the first element
- Multiply the elements together
- Sum the elements together
- Divide the first element by the second

Luckily, these can be very easily represented in q using `first`, `prd`, `sum` and `(div).` (the dot
in the last one is the multivalued apply operator). (Fun fact: statistically "first" is the most
common one, followed by "prd". "Sum" is only used for 2 or 3 nodes, and "div" is only used for a
single node, which also happens to be the one that outputs to the NAT.

The nodes operate in the following way, which seems to mimic a neural network. There is a special
case in the beginning that if a -1 is received, the node will attempt to broadcast its data. This
will only work if all the data buffer cells are filled in. The usual solution will feed a -1 right
at the beginning to every node and thus trigger this special case immediately. Once attempted, a -1
will never try to do the broadcast again, and will simply be discarded with no action. If a valid
message is received, it is interpreted as a command to set a specific value in the data buffer. The
X value is the index into the data buffer plus one, multiplied by the node's address multiplier.
Therefore the node first divides the X value by its address multiplier and then subtracts 1. This
must be a valid index into the data buffer, otherwise the input is ignored. The Y value is written
to the specified cell in the data buffer, and the "is full" flag is set. If the write operation
caused a change in the data buffer, a broadcast is attempted (the same way as the initial -1 case).

Before performing the broadcast, the node checks if all data buffer cells are filled in. If not then
it goes back to the beginning of the loop to read more input. If all cells are filled, it calls the
data processing function which performs the particular operation on the data buffer cells. The
result is the Y value to broadcast. Finally it goes through the destination list and outputs each
destination with the Y value after each one. Therefore every change in the data buffer causes the
same value to be sent to each node+cell in the destination list.

The implementation is still a straightforward simulation, except by performing the operations on the
numbers directly instead of using the intcode interpreter. This day seems to be the one that
benefits the least from whiteboxing (other than the early days where the functionality of the
interpreter itself is being tested).

Helper function to get the initialization values for each node:
```q
.d23.getInitVals:{[init]
    ji:where init in 1105 1106;
    ji:first ji where init[ji+2]=73;
    cmds:4 cut ji#init;
    vals:first each cmds[;1 2] except\:0 1;
    vals[where 1101 0 0~/:3#/:cmds]:0;
    vals[where 1101 1 0~/:3#/:cmds]:1;
    vals[where 1101 0 1~/:3#/:cmds]:1;
    vals[where 1102 0 1~/:3#/:cmds]:0;
    vals[where 1102 1 0~/:3#/:cmds]:0;
    vals[where 1102 1 1~/:3#/:cmds]:1;
    vals};
```
The solution function takes an extra parameter, `part`, that can be 1 or 2.
```q
q)part:2
```
We find the addresses of the initialization functions and put them in ascending order:
```q
q)inits:a[11+til 50]
q)inits
1237 987 2190 1391 1323 1612 2033 643 571 1278 1705 1515 781 612 717 884 1581 1142 814 1016 1641 1..
q)ai:asc[inits]
q)ai
`s#571 612 643 686 717 750 781 814 853 884 921 952 987 1016 1047 1076 1107 1142 1173 1206 1237 127..
```
We cut the code on these offsets to extract the initialization code blocks:
```q
q)inits2:(ai!ai cut a)inits
q)inits2
1101 16979 0 66 1102 1 1 67 1101 1264 0 68 1102 1 556 69 1101 6 0 71 1101 0 1266 72 1105 1 73 1 28..
1102 63577 1 66 1102 1 1 67 1102 1014 1 68 1102 1 556 69 1102 1 0 71 1101 0 1016 72 1105 1 73 1 1932
1102 1 12689 66 1101 1 0 67 1102 2217 1 68 1101 0 556 69 1102 1 3 71 1101 0 2219 72 1106 0 73 1 5 ..
1102 1 49783 66 1101 1 0 67 1102 1 1418 68 1102 1 556 69 1102 1 1 71 1102 1 1420 72 1105 1 73 1 64..
..
```
We find the initial values from the code blocks:
```q
q)initVals:.d23.getInitVals each inits2
q)initVals
16979 1 1264 556 6 1266
63577 1 1014 556 0 1016
12689 1 2217 556 3 2219
49783 1 1418 556 1 1420
..
```
We store the address divisors in their own list:
```q
q)addrDiv:initVals[;0]
q)addrDiv
16979 63577 12689 49783 50363 87679 65981 31267 3557 97379 56897 81761 48487 17359 83089 74197 572..
```
We map the processing functions to their q implementations. These are always found at the same
addresses across different inputs, so we can map the locations to the functions directly.
```q
q)fns:(556 302 253 351!(first;prd;sum;(div).))initVals[;3]
q)fns
*:
*:
*:
*:
*:
*:
prd
prd
prd
*:
*:
*:
*:
*:
*:
prd
*:
*:
sum
*:
*:
*:
..
```
We extract the output buffer contents for each node:
```q
q)outs:2 cut/:a[initVals[;5]+til each 2*initVals[;4]]
q)outs
(39 76651;26 42571;26 85142;37 96589;37 193178;37 289767)
()
(15 148394;15 296788;8 14228)
,18 230455
,8 3557
()
..
```
We extract the input buffer contents for each node:
```q
q)ins:2 cut/:a[initVals[;2]+til each 2*initVals[;1]]
q)ins
,1 28154
,1 1932
,1 5
,1 6468
,1 160
,1 1161
(0 0;0 0;0 0)
(0 0;0 0;0 0;0 0;0 0;0 0;0 0)
(0 0;0 0;0 0;0 0;0 0;0 0)
```
To perform the initial send, we find which nodes are "senders", which means they have outputs and
all of their inputs have their "full" flags set:
```q
q)senders:where (0<count each outs) and all each ins[;;0]
q)senders
0 2 3 4 9 10 11 12 13 14 16 17 19 20 24 25 27 28 29 30 31 33 34 36 48
```
We find the values to be sent by performing the senders' processing functions on their input
buffers:
```q
q)sendVals:(fns senders)@' ins[senders;;1]
q)sendVals
28154 5 6468 160 1 1489 2 10 379 131 -10 191 13 5737 1321 -143 31 1487 3 165 56 11 -23 125 -40519
```
We find the messages to send by concatenating the values to every entry in the output buffer:
```q
q)sendMsg:outs[senders],\:'sendVals
q)sendMsg
(39 76651 28154;26 42571 28154;26 85142 28154;37 96589 28154;37 193178 28154;37 289767 28154)
(15 148394 5;15 296788 5;8 14228 5)
,18 230455 6468
,8 3557 160
(7 156335 1;35 114843 1;22 54118 1;41 103738 1;46 67499 1;43 248277 1;6 65981 1;45 113548 1)
..
q)sendMsg2:raze sendMsg
q)sendMsg2
39 76651  28154
26 42571  28154
26 85142  28154
37 96589  28154
37 193178 28154
37 289767 28154
15 148394 5
15 296788 5
8  14228  5
..
```
We group the messages by recipient:
```q
q)sendMsg3:(1_/:sendMsg2) (group sendMsg2[;0])
q)sendMsg3
39| ,76651 28154
26| (42571 28154;85142 28154)
37| (96589 28154;193178 28154;289767 28154)
15| (148394 5;296788 5;222591 10;74197 125)
8 | (14228 5;3557 160;10671 2;17785 2;7114 10)
18| ,230455 6468
..
```
We initialize an input queue and add the initial messages:
```q
q)inq:50#enlist()
q)inq[key sendMsg3]:value sendMsg3
q)inq
()
()
()
()
()
()
(65981 1;131962 5737;197943 56)
(156335 1;187602 1489;93801 131;31267 13;125068 1487;218869 11;62534 -23)
(14228 5;3557 160;10671 2;17785 2;7114 10)
..
```
Before starting the iteration, we initialize the NAT content and history to empty lists:
```q
q)nat:0#0
q)natHist:0#0
```
Just like in the regular solution, we do an "infinite" iteration:
```q
    while[1b;
        ...
    ];
```
In the iteration, we first check which nodes are due to receive messages:
```q
q)receivers:where 0<count each inq
q)receivers
6 7 8 15 18 22 26 35 37 39 41 42 43 45 46
```
If there are none, we do the processing on the NAT like in the regular solution, including returning
any duplicated hisory entry for part 2:
```q
    if[0=count receivers;
        if[last[natHist]=last nat; :last nat];
        natHist,:last nat;
        inq[0],:enlist nat;
        receivers:where 0<count each inq;
    ];
```
We extract the first message that each receiver is going to receive:
```q
q)recvMsg:first each inq[receivers]
q)recvMsg
65981  1
156335 1
14228  5
148394 5
230455 6468
54118  1
42571  28154
114843 1
96589  28154
76651  28154
103738 1
82763  191
248277 1
113548 1
67499  1
```
We drop these messages from the input queues:
```q
q)inq[receivers]:1_/:inq[receivers]
q)inq
()
()
()
()
()
()
(131962 5737;197943 56)
(187602 1489;93801 131;31267 13;125068 1487;218869 11;62534 -23)
(3557 160;10671 2;17785 2;7114 10)
..
```
We find the target slots in the receivers' input buffers by dividing the X values by the nodes'
address divisors and subtracting one:
```q
q)recvPos:(recvMsg[;0]div addrDiv[receivers])-1
q)recvPos
0 4 3 1 4 1 0 2 0 0 1 0 2 3 0
```
We extract the received data values:
```q
q)recvData:recvMsg[;1]
q)recvData
1 1 5 5 6468 1 28154 1 28154 28154 1 191 1 1 1
```
We back up the previous state of the input buffers and place the received data in the correct slots:
```q
q)prevIns:ins
q)ins:{[ins;m;p;d].[ins;(m;p);:;(1;d)]}/[ins;receivers;recvPos;recvData]
q)ins
,1 28154
,1 1932
,1 5
,1 6468
,1 160
,1 1161
(1 1;0 0;0 0)
(0 0;0 0;0 0;0 0;1 1;0 0;0 0)
(0 0;0 0;0 0;1 5;0 0;0 0)
..
```
We check which of the nodes have any input values changed, as this may cause them to send:
```q
q)changed:where not prevIns~'ins
q)changed
6 7 8 15 18 22 26 35 37 39 41 42 43 45 46
```
We check which of the nodes with their inputs changed actually have all of their inputs filled:
```q
q)changed
6 7 8 15 18 22 26 35 37 39 41 42 43 45 46
q)senders:changed where (0<count each outs changed) and all each ins[changed;;0]
q)senders
`long$()
```
We find the sent values and append to the input queues just like how it was done before the
iteration:
```q
    sendVals:(fns senders)@' ins[senders;;1];
    sendMsg:outs[senders],\:'sendVals;
    sendMsg2:raze sendMsg;
    sendMsg3:(1_/:sendMsg2) (group sendMsg2[;0]);
    ...
    inq[key sendMsg3],:value sendMsg3;
```
The missing bit is a check on the NAT receiving a message. If the ID 255 appears in the sent
messages, we either return it (for part 1) or put it into the NAT and remove it from the sent
messages:
```q
    if[255 in key sendMsg3;
        if[part=1;:first[sendMsg3 255][1]];
        nat:last sendMsg3[255];
        sendMsg3:enlist[255]_sendMsg3;
    ];
```
This is the end of the code for the iteration.

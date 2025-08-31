# Breakdown
A straightforward simulation.

Example input:
```q
x:()
x,:"\n"vs"Player 1:\n9\n2\n6\n3\n1\n"
x,:"\n"vs"Player 2:\n5\n8\n4\n7\n10"
```
We parse the decks by splitting on double newline, then on single newline, and dropping the
"Player:" lines:
```q
q)decks:"J"$1_/:"\n"vs/:"\n\n"vs"\n"sv x
q)decks
9 2 6 3 1
5 8 4 7 10
```
We iterate until either player runs out of cards. This can be expressed as the product of the counts
of the two decks being non-zero.
```q
    while[0<prd count each decks;
        ...
    ];
```
In each step, we compare the two top cards:
```q
    $[decks[0;0]>decks[1;0];
        ...
    ]
```
The two branches correspond to the two players winning. In both cases we reconstruct the two decks
from their parts, dropping the fron card and adding the two winning cards into the deck of the
player who won the current round.
```q
    $[decks[0;0]>decks[1;0];
        decks:((1_decks[0]),decks[0;0],decks[1;0];1_decks[1]);
        decks:(1_decks[0];(1_decks[1]),decks[1;0],decks[0;0])];
    ]
```
At the end of the iteration, we have the final state of the two players' decks:
```q
q)decks
`long$()
3 2 10 6 8 5 9 4 7 1
```
We extract the cards in the order to sum them up in by razing the two lists together (this is easier
than having a branch to check which one is not empty) and reversing the result:
```q
q)cards:reverse raze decks
q)cards
1 7 4 9 5 8 6 10 2 3
```
We can generate the multipliers using `til`, we just have to add 1 to start from the correct number.
```q
q)1+til count cards
1 2 3 4 5 6 7 8 9 10
q)sum(1+til count cards)*cards
306
```

## Part 2
We don't use actual recursion but maintain a stack using a list that gets the visited game states
and the decks pushed into it. This solution is slow due to all the array shuffling and the lack of a
hashed data structure to check for already visited states.

We parse the decks as in part 1 and initialize variables for the memo and stack with empty lists.
```q
q)decks:"J"$1_/:"\n"vs/:"\n\n"vs"\n"sv x
q)memo:()
q)stack:()
```
Once again we iterate until either player runs out of cards:
```q
    while[0<prd count each decks;
        ...
    ];
```
In the iteration, we check if the current configuration is in the memo. If it is, we clear the deck
of player 2.
```q
    $[first enlist[decks] in memo;
        decks[1]:`long$();
```
Next, we check if any player has a card that is higher than the count of their remaining cards:
```q
    any(first each decks)>-1+count each decks;
```
In this case, we add the current deck configuration to the memo and exchange the cards like in part
1:
```q
    [memo,:enlist decks;
    $[decks[0;0]>decks[1;0];
        decks:((1_decks[0]),decks[0;0],decks[1;0];1_decks[1]);
        decks:(1_decks[0];(1_decks[1]),decks[1;0],decks[0;0])];
    ];
```
If neither condition is true, we need to start a nested game. So we save the current state in the
stack, including `memo` and `decks`, replace `memo` with an empty one, and pull the necessary cards
into the inner `decks`.
```q
    [stack:stack,enlist(memo;decks);memo:();decks:decks[;0]#'1_/:decks]
```
We still have to check the exit condition of a nested game. This happens as a separate step from the
above conditional. The condition to check for exit is is the stack not being empty and one of the
decks being empty. Since q has no short-circuit boolean evaluation, this needs to be done using a
nested if:
```q
    if[0<count stack;if[any 0=count each decks;
        ...
    ]];
```
If this condition is true, we start by determining the winner based on who has cards left:
```q
    winner:first where 0<count each decks;
```
We pop the last state from the stack:
```q
    memo:first last stack;
    decks:last last stack;
    stack:-1_stack;
```
We add the current deck configuration to the memo:
```q
    memo,:enlist decks;
```
We determine which order to pull the first cards to add to the winner's hand:
```q
    moveCards:decks[winner;0],decks[1-winner;0];
```
We drop the first card from each deck and append the winner's cards to their respective deck:
```q
    decks:(1_/:decks);
    decks[winner],:moveCards;
```
At the end of the iteration, we have the final state of the two players' decks, which we process
as in part 1:
```q
q)decks
`long$()
7 5 6 2 4 1 10 8 9 3
q)cards:reverse raze decks
q)cards
3 9 8 10 1 4 2 6 5 7
q)sum(1+til count cards)*cards
291
```

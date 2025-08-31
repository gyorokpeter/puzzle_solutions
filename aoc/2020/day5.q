d5:{0b sv/:(6#0b),/:("FBLR"!0101b)x};
d5p1:{max d5[x]};
d5p2:{s:asc d5[x];-1+s last where 1<deltas s};

/
x:"\n"vs"BFFFBBFRRR\nFFFBBBFRRR\nBBFFBBFRLL";

d5p1 x  //820
//d5p2 x
// Part 2 for this day is not possible to demonstrate on an example input.

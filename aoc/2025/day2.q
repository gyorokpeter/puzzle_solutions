d2:{a:"-"vs/:","vs raze x;
    cs:count each/:a;
    (a;cs)};
d2rep:{[rep;a;cs]
    half:first each(cs@'where each 0=cs mod rep)div rep;
    valid:where not null half;
    (a2;half2):(a;half)@\:valid;
    lo:("J"$"1",/:(half2-1)#\:"0")or"J"$neg[half2*rep-1]_'a2[;0];
    hi:("J"$half2#\:"9")and"J"$neg[half2*rep-1]_'a2[;1];
    poss:string lo+til each 0 or 1+hi-lo;
    poss2:"J"$(rep*count each/:poss)#''poss;
    raze poss2@'where each poss2 within'"J"$a2};
d2p1:{(a;cs):d2 x;
    sum d2rep[2;a;cs]};
d2p2:{(a;cs):d2 x;
    sum distinct raze d2rep[;a;cs]each 2+til -1+max max cs};

/
x:();
x,:enlist"11-22,95-115,998-1012,1188511880-1188511890,222220-222224,";
x,:enlist"1698522-1698528,446443-446449,38593856-38593862,565653-565659,";
x,:enlist"824824821-824824827,2121212118-2121212124";

d2p1 x  //1227775554
d2p2 x  //4174379265

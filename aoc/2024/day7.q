d7:{[ops;x]a:": "vs/:x; t:"J"$a[;0]; n:"J"$" "vs/:a[;1];
    op:cross[;ops]\[max[count each n]-1;enlist()];
    sum t where t in'{{y[x;z]}/[x 0;;1_x]'[y]}'[n;op -1+count each n]};
d7p1:{d7[(+;*);x]};
d7p2:{d7[(+;*;{"J"$raze string(x;y)});x]};

/

x:"\n"vs"190: 10 19\n3267: 81 40 27\n83: 17 5\n156: 15 6\n7290: 6 8 6 15";
x,:"\n"vs"161011: 16 10 13\n192: 17 8 14\n21037: 9 7 18 13\n292: 11 6 16 20";

d7p1 x  //3749
d7p2 x  //11387

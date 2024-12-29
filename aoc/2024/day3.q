d3p1:{a:raze x;
    b:"J"$","vs/:first each ")"vs/:1_"mul("vs a;
    c:{x where 2=count each x}{x where not 0N in/:x}b;
    sum(*)./:c};
d3p2:{a:"do()"vs/:"don't()"vs raze x;
    d3p1 a[0],raze 1_/:1_a};

/

x:"xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";
x2:"xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))";

d3p1 x  //161
//d3p2 x
d3p2 x2  //48

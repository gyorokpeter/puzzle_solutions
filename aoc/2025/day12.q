d12:{
    a:"\n\n"vs"\n"sv x;
    shsz:sum each sum each "#"=-1_a;
    b:": "vs/:"\n"vs last a;
    flds:"J"$"x"vs/:b[;0];
    fldc:"J"$" "vs/:b[;1];
    tooBig:(prd each flds)<sum each shsz*/:fldc;
    trivialFill:(prd each flds div 3)>=sum each fldc;
    if[any bad:where not tooBig or trivialFill;'"nontrivial cases: ",","sv string bad];
    sum trivialFill};

/
// solution does not work on example input

x:read0`:day12.in

d12p1 x

d5p1:{a:"\n\n"vs"\n"sv x;
    b:"J"$"|"vs/:"\n"vs a 0;
    c:"J"$","vs/:"\n"vs a 1;
    d:c where not any each({reverse each(-1_x),'1_x}each c)in\:b;
    sum d@'(count each d)div 2};
d5p2:{a:"\n\n"vs"\n"sv x;
    b:"J"$"|"vs/:"\n"vs a 0;
    c:"J"$","vs/:"\n"vs a 1;
    bad:();
    while[1b;
        d:{reverse each(-1_x),'1_x}each c;
        e:where each d in\:b;
        if[0=count bad; bad:where 0<count each e];
        if[0=count raze e; :sum(c@'(count each c)div 2)bad];
        f:(d@'e)[;;1];
        c:(c except'f),'f;
    ]};

/

x:"\n"vs"47|53\n97|13\n97|61\n97|47\n75|29\n61|13\n75|53\n29|13\n97|29\n53|29\n61|53\n97|53";
x,:"\n"vs"61|29\n47|13\n75|47\n97|75\n47|61\n75|61\n47|29\n75|13\n53|13\n";
x,:"\n"vs"75,47,61,53,29\n97,61,53,29,13\n75,29,13\n75,97,47,61,53\n61,13,29\n97,13,75,29,47";

d5p1 x  //143
d5p2 x  //123

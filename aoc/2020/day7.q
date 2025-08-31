d7:{a:" bags contain " vs/:x;
    b:{?[x~\:"no other bags.";count[x]#enlist();", "vs/:x]}a[;1];
    c:-1_/:/:" "vs/:/:b;
    (`$a[;0])!c};
d7p1:{
    ac:d7 x;
    d:`$" "sv/:/:1_/:/:ac;
    e:{distinct each x,'raze each x x}/[d];
    sum(`$"shiny gold")in/:e};
d7p2:{
    ac:d7 x;
    d:("J"$ac[;;0]),''`$" "sv/:/:1_/:/:ac;
    g:{[d;x]e:d key x;
        e[;;0]*:value x;
        f:e where 0<count each e;
        ((`$())!0#0),sum(!).'reverse each flip each f}[d]\[enlist[`$"shiny gold"]!enlist 1];
    -1+sum raze value each g};

/
x: ("light red bags contain 1 bright white bag, 2 muted yellow bags.";
    "dark orange bags contain 3 bright white bags, 4 muted yellow bags.";
    "bright white bags contain 1 shiny gold bag.";
    "muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.";
    "shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.";
    "dark olive bags contain 3 faded blue bags, 4 dotted black bags.";
    "vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.";
    "faded blue bags contain no other bags.";
    "dotted black bags contain no other bags.");
x2:("shiny gold bags contain 2 dark red bags.";
    "dark red bags contain 2 dark orange bags.";
    "dark orange bags contain 2 dark yellow bags.";
    "dark yellow bags contain 2 dark green bags.";
    "dark green bags contain 2 dark blue bags.";
    "dark blue bags contain 2 dark violet bags.";
    "dark violet bags contain no other bags.");

d7p1 x  //4
//d7p2 x
d7p2 x2 //126

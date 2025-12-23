d6p1:{st:flip`s`t!flip`$")"vs/:x;
    childMap:exec t by s from st;
    childMap:{distinct each raze each x,'x x}/[childMap];
    sum count each childMap};
d6p2:{st:flip`s`t!flip`$")"vs/:x;
    parent:exec t!s from st;
    youPath:parent\[`YOU];
    sanPath:parent\[`SAN];
    (count[youPath except sanPath]-1)+(count[sanPath except youPath]-1)};

/
x:"\n"vs"COM)B\nB)C\nC)D\nD)E\nE)F\nB)G\nG)H\nD)I\nE)J\nJ)K\nK)L"
x2:"\n"vs"COM)B\nB)C\nC)D\nD)E\nE)F\nB)G\nG)H\nD)I\nE)J\nJ)K\nK)L\nK)YOU\nI)SAN"

d6p1 x  //42
d6p1 x2 //54
d6p2 x  //0
d6p2 x2 //4

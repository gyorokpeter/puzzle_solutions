d6:{[c;x]x:first x;c+first where c=count each distinct each x til[c]+/:til count[x]-c-1};
d6p1:{d6[4;x]};
d6p2:{d6[14;x]};

/

//alternatives
x:"\n"vs"mjqjpqmgbljsphdztnvjfqwrcgsmlb";
x:"\n"vs"bvwbjplbgvbhsrlpgdmjqwftvncz";
x:"\n"vs"nppdvjthqldpwncqszvftbrmjlhg";
x:"\n"vs"nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg";
x:"\n"vs"zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw";

d6p1 x  //7 / 5 / 6 / 10 / 11
d6p2 x  //19 / 23 / 23 / 29 / 26

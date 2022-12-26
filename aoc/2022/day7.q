d7:{a:" "vs/:x;
    pwd:{$[not y[0]~enlist"$";x;
        y[1]~"ls";x;
        y[2]~enlist"/";enlist"";
        y[2]~"..";-1_x;
        x,enlist last[x],"/",y 2]}\[enlist"";a];
    fs:"J"$first each a;
    exec sum fs by pwd from ungroup ([]pwd;fs)};
d7p1:{t:d7 x;sum t where t<=100000};
d7p2:{t:d7 x;min t where 30000000<=t+70000000-t[""]};

/
x:"\n"vs"$ cd /\n$ ls\ndir a\n14848514 b.txt\n8504156 c.dat\ndir d\n$ cd a\n$ ls\ndir e\n29116 f\n2557 g\n62596 h.lst\n$ cd e\n$ ls\n584 i\n$ cd ..\n$ cd ..\n$ cd d\n$ ls\n4060174 j\n8033020 d.log\n5626152 d.ext\n7214296 k";

d7p1 x  //95437
d7p2 x  //24933642

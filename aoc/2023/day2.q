d2:{a:" "vs/:/:/:", "vs/:/:"; "vs/:last each": "vs/:x;
    num:"J"$a[;;;0]; typ:("red";"green";"blue")?a[;;;1];
    @[0 0 0;;:;]''[typ;num]};
d2p1:{sum 1+where all each all each/:12 13 14>=/:/:d2 x};
d2p2:{sum prd each max each d2 x};

/
x:();
x,:enlist"Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green";
x,:enlist"Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue";
x,:enlist"Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red";
x,:enlist"Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red";
x,:enlist"Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green";

d2p1 x  //8
d2p2 x  //2286

d11:{(`n`ne`se`s`sw`nw!(0 1 -1;1 0 -1;1 -1 0;0 -1 1;-1 0 1;-1 1 0))`$","vs first x};
d11p1:{max abs sum d11 x};
d11p2:{max max each abs sums d11 x};

/
d11p1 enlist"ne,ne,ne" //3
d11p1 enlist"ne,ne,sw,sw" //0
d11p1 enlist"ne,ne,s,s" //2
d11p1 enlist"se,sw,se,sw,sw"   //3

d11p2 enlist"ne,ne,ne" //3
d11p2 enlist"ne,ne,sw,sw" //2
d11p2 enlist"ne,ne,s,s" //2
d11p2 enlist"se,sw,se,sw,sw"   //3

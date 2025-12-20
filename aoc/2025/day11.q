d11p1:{
    a:": "vs/:x;
    adj:(`$a[;0])!`$" "vs/:a[;1];
    goal:0;
    queue:([]n:enlist`you;c:1);
    while[count queue;
        nxts:ungroup update nn:adj n from queue;
        goal+:exec sum c from nxts where nn=`out;
        queue:0!select sum c by n:nn from nxts;
    ];
    goal};
d11p2:{
    a:": "vs/:x;
    adj:(`$a[;0])!`$" "vs/:a[;1];
    goal:0;
    queue:([]n:enlist`svr;c:1;fft:0b;dac:0b);
    while[count queue;
        nxts:update fft:fft or nn=`fft,dac:dac or nn=`dac from ungroup update nn:adj n from queue;
        goal+:exec sum c from nxts where nn=`out,fft,dac;
        queue:0!select sum c by n:nn,fft,dac from nxts;
    ];
    goal};

/
x:"\n"vs"aaa: you hhh\nyou: bbb ccc\nbbb: ddd eee\nccc: ddd eee fff\nddd: ggg\neee: out";
x,:"\n"vs"fff: out\nggg: out\nhhh: ccc fff iii\niii: out";

x2:"\n"vs"svr: aaa bbb\naaa: fft\nfft: ccc\nbbb: tty\ntty: ccc\nccc: ddd eee\nddd: hub";
x2,:"\n"vs"hub: fff\neee: dac\ndac: fff\nfff: ggg hhh\nggg: out\nhhh: out";

d11p1 x     //5
//d11p2 x
d11p2 x2    //2

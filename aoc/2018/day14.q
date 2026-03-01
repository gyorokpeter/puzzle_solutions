d14p1:{
    c:"J"$x;
    r:3 7;
    curr0:0;
    curr1:1;
    while[count[r]<10+c;
        d0:r curr0;
        d1:r curr1;
        r,:"J"$/:string d0+d1;
        curr0:(1+curr0+d0)mod count r;
        curr1:(1+curr1+d1)mod count r;
    ];
    raze string 10#c _r};
d14p2:{
    c:"J"$/:x;
    r:3 7;
    curr0:0;
    curr1:1;
    cc:count c;
    while[1b;
        d0:r curr0;
        d1:r curr1;
        ds:"J"$/:string d0+d1;
        r,:ds;
        if[count[c]<=count[r];
            if[c~neg[cc]#r;:count[r]-cc];
            if[2=count ds;if[c~-1_(-1+neg cc)#r;:count[r]-cc+1]];
        ];
        curr0:(1+curr0+d0)mod count r;
        curr1:(1+curr1+d1)mod count r;
    ];
    };

/
No imput file, the input is a string (interpreted as an integer for part 1).
x:"9";
x2:"5";
x3:"18";
x4:"2018";
x5:"51589";
x6:"01245";
x7:"92510";
x8:"59414";

d14p1 x     //"5158916779"
d14p1 x2    //"0124515891"
d14p1 x3    //"9251071085"
d14p1 x4    //"5941429882"
//d14p2 x
d14p2 x5    //9
d14p2 x6    //5
d14p2 x7    //18
d14p2 x8    //2018

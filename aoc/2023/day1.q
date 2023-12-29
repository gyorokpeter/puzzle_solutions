d1p1:{sum"J"${(first each x),'last each x}x inter\:1_.Q.n};
d1p2:{a:x ss/:\:("one";"two";"three";"four";"five";"six";"seven";"eight";"nine"),enlist each 1_.Q.n;
    pfirst:min each raze each a;
    plast:max each raze each a;
    dfirst:first each where each pfirst in/:'a;
    dlast:first each where each plast in/:'a;
    sum 10 sv/:1+(dfirst,'dlast)mod 9};

/
x:"\n"vs"1abc2\npqr3stu8vwx\na1b2c3d4e5f\ntreb7uchet";
d1p1 x  //142
x:"\n"vs"two1nine\neightwothree\nabcone2threexyz\nxtwone3four\n4nineeightseven2\nzoneight234\n7pqrstsixteen";
d1p2 x  //281

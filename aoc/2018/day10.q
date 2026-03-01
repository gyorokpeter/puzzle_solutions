d10prep:{
    a:"J"$", "vs/:/:first each/:-1_/:/:1_/:">"vs/:/:"<"vs/:x;
    pos:a[;0];
    spd:a[;1];
    turns:`long$max abs(pos[;0]%spd[;0])except 0w;
    states:pos+/:spd*/:turns+-300+til 400;
    sizes:{max[x[;0]]-min x[;0]}each states;
    delay:first where sizes=min sizes;
    (states delay;-300+turns+delay)};
d10p1:{
    st:first d10prep x;
    st:st-\:(min st[;0];min[st[;1]]);
    grid:(1+max st[;0];1+max st[;1])#0;
    msg:" #"flip 0<./[;;+;1][grid;st];
    letters:raze each 6#/:/:flip 8 cut/:msg;
    ocr:enlist[""]!enlist"?";
    ocr["  ##   #  # #    ##    ##    ########    ##    ##    ##    #"]:"A";
    ocr[" #### #    ##     #     #     #     #     #     #    # #### "]:"C";
    ocr["#     #     #     #     #     #     #     #     #     ######"]:"L";
    ocr["#    ###   ###   ## #  ## #  ##  # ##  # ##   ###   ###    #"]:"N";
    ocr["##### #    ##    ##    ###### #  #  #   # #   # #    ##    #"]:"R";
    ocr["######     #     #    #    #    #    #    #     #     ######"]:"Z";
    ocr letters};
d10p2:{last d10prep x};

/
x:();
x,:"\n"vs"position=< 9,  1> velocity=< 0,  2>\nposition=< 7,  0> velocity=<-1,  0>";
x,:"\n"vs"position=< 3, -2> velocity=<-1,  1>\nposition=< 6, 10> velocity=<-2, -1>";
x,:"\n"vs"position=< 2, -4> velocity=< 2,  2>\nposition=<-6, 10> velocity=< 2, -2>";
x,:"\n"vs"position=< 1,  8> velocity=< 1, -1>\nposition=< 1,  7> velocity=< 1,  0>";
x,:"\n"vs"position=<-3, 11> velocity=< 1, -2>\nposition=< 7,  6> velocity=<-1, -1>";
x,:"\n"vs"position=<-2,  3> velocity=< 1,  0>\nposition=<-4,  3> velocity=< 2,  0>";
x,:"\n"vs"position=<10, -3> velocity=<-1,  1>\nposition=< 5, 11> velocity=< 1, -2>";
x,:"\n"vs"position=< 4,  7> velocity=< 0, -1>\nposition=< 8, -2> velocity=< 0,  1>";
x,:"\n"vs"position=<15,  0> velocity=<-2,  0>\nposition=< 1,  6> velocity=< 1,  0>";
x,:"\n"vs"position=< 8,  9> velocity=< 0, -1>\nposition=< 3,  3> velocity=<-1,  1>";
x,:"\n"vs"position=< 0,  5> velocity=< 0, -1>\nposition=<-2,  2> velocity=< 2,  0>";
x,:"\n"vs"position=< 5, -2> velocity=< 1,  2>\nposition=< 1,  4> velocity=< 2,  1>";
x,:"\n"vs"position=<-2,  7> velocity=< 2, -2>\nposition=< 3,  6> velocity=<-1, -1>";
x,:"\n"vs"position=< 5,  0> velocity=< 1,  0>\nposition=<-6,  0> velocity=< 2,  0>";
x,:"\n"vs"position=< 5,  9> velocity=< 1, -2>\nposition=<14,  7> velocity=<-2,  0>";
x,:enlist"position=<-3,  6> velocity=< 2, -1>";

//d10p1 x
d10p2 x //3

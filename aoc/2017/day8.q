d8:{{[rm;x]
        reg:rm 0;
        p:" "vs x;
        cond:(("==";"!=";">=";"<=";enlist"<";enlist">")!(=;<>;<=;>=;<;>))p 5;
        if[cond[0^reg`$p 4;"J"$p 6];
            reg[`$p 0]+:$["dec"~p 1;-1;1]*"J"$p 2];
        (reg;rm[1],max reg)
    }/[((`$())!`long$();`long$());x]};
d8p1:{last last d8 x};
d8p2:{max last d8 x};

/
x:"\n"vs"b inc 5 if a > 1\na inc 1 if b < 5\nc dec -10 if a >= 1\nc inc -20 if c == 10";

d8p1 x   //1
d8p2 x   //10

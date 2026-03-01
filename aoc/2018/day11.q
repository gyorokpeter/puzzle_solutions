d11tbl:{[seed]
    sz:300;
    a:sz#enlist 11+til sz;
    b:(((a*seed+(1+til sz)*'a)div 100)mod 10)-5;
    b};
d11common:{[tbl;wnd]
    s:(wnd-1)_/:wnd msum/:(wnd-1)_wnd msum tbl;
    ms:max max s;
    mloc:first raze {til[count x],/:'x}where each s=ms;
    (ms;","sv string 1+reverse mloc)};
d11p1:{last d11common[d11tbl x;3]};
d11p2:{tmp:d11common[d11tbl x]each 1+til 300;
    best:{first where x=max x}first each tmp;
    last[tmp best],",",string[1+best]};

/
No input file, the input is an integer.
x:18;

d11p1 x //"33,45"
d11p2 x //"90,269,16"

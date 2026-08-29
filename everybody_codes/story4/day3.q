d3p1:{a:last each"="vs/:x;
    (w;h):"J"$2#a;
    (ho;vo):"J"$/:/:a 2 3;
    vpat:(h+1)#ho;
    hpat:(w+1)#vo;
    hb:{(1_x)and -1_x}(vpat-\:w#10b)mod 2;
    vb:flip{(1_x)and -1_x}(hpat-\:h#10b) mod 2;
    sum sum hb and vb};
d3p2:{a:last each"="vs/:x;
    (w;h):"J"$2#a;
    (ho;vo):"J"$/:/:a 2 3;
    tw:2*count vo;th:2*count ho;
    mw:min(w;tw+w mod tw);
    mh:min(h;th+h mod th);
    htc:w div tw;vtc:h div th;
    vpat:(mh+1)#ho;
    hpat:(mw+1)#vo;
    he:(vpat-\:mw#10b)mod 2;
    ve:(hpat-\:mh#10b) mod 2;
    hb:{(1_x)and -1_x}he;
    vb:flip{(1_x)and -1_x}ve;
    iso:hb and vb;
    leftc:(0,0+\1_-1_he[;0])mod 2;
    color:flip (enlist[leftc],leftc+\1_-1_ve)mod 2;
    isoA:`long$sum each/:sum each(0;th)cut(0;tw)cut/:iso and color;
    isoB:`long$sum each/:sum each(0;th)cut(0;tw)cut/:iso and not color;
    totalA:sum 0^(isoA[1;1];htc*isoA[1;0];vtc*isoA[0;1];htc*vtc*isoA[0;0]);
    totalB:sum 0^(isoB[1;1];htc*isoB[1;0];vtc*isoB[0;1];htc*vtc*isoB[0;0]);
    max(totalA;totalB)};

/
x:();
x,:enlist"width=30";
x,:enlist"height=10";
x,:enlist"horizontal-offsets=10011";
x,:enlist"vertical-offsets=11011";

x2:();
x2,:enlist"width=100";
x2,:enlist"height=70";
x2,:enlist"horizontal-offsets=111101111101101111000100100110";
x2,:enlist"vertical-offsets=110100001110111011101000001111";

d3p1 x  //27
d3p2 x  //15
d3p2 x2 //269

d3p1 read0`:everybody_codes_e4_q03_p1.txt
d3p2 read0`:everybody_codes_e4_q03_p2.txt
d3p2 read0`:everybody_codes_e4_q03_p3.txt

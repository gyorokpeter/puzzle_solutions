d15p1:{[line;x]a:"J"$2_/:/:(" "vs/:x except\:",:")[;2 3 8 9];
    range:sum each abs a[;0 1]-a[;2 3];
    nr:range-abs line-a[;1];
    xs:flip a[;0]+/:(neg nr;nr);
    xs:asc xs where 0<=nr;
    merged:{$[last[x][1]>=y[0];x[count[x]-1;1]|:y[1];x,:enlist y];x}/[1#xs;1_xs];
    overlap:sum sum(distinct a[;2]where line=a[;3]) within/:merged;
    sum[1+merged[;1]-merged[;0]]-overlap};
d15p2:{[line;x]
    lim:2*line;
    a:"J"$2_/:/:(" "vs/:x except\:",:")[;2 3 8 9];
    range:sum each abs a[;0 1]-a[;2 3];
    cover:{[a;range;lim;line]
        if[0=line mod 1000;show line];
        nr:range-abs line-a[;1];
        xs:flip a[;0]+/:(neg nr;nr);
        xs[;0]|:0; xs[;1]&:lim;
        xs:asc xs where 0<=nr;
        {$[last[x][1]>=y[0]-1;x[count[x]-1;1]|:y[1];x,:enlist y];x}/[1#xs;1_xs]
        }[a;range;lim]each til 1+lim;
    c:where 2=count each cover;
    cc:1+cover[c;0;1];
    c+4000000*cc};

/
x:enlist"Sensor at x=2, y=18: closest beacon is at x=-2, y=15";
x,:enlist"Sensor at x=9, y=16: closest beacon is at x=10, y=16";
x,:enlist"Sensor at x=13, y=2: closest beacon is at x=15, y=3";
x,:enlist"Sensor at x=12, y=14: closest beacon is at x=10, y=16";
x,:enlist"Sensor at x=10, y=20: closest beacon is at x=10, y=16";
x,:enlist"Sensor at x=14, y=17: closest beacon is at x=10, y=16";
x,:enlist"Sensor at x=8, y=7: closest beacon is at x=2, y=10";
x,:enlist"Sensor at x=2, y=0: closest beacon is at x=2, y=10";
x,:enlist"Sensor at x=0, y=11: closest beacon is at x=2, y=10";
x,:enlist"Sensor at x=20, y=14: closest beacon is at x=25, y=17";
x,:enlist"Sensor at x=17, y=20: closest beacon is at x=21, y=22";
x,:enlist"Sensor at x=16, y=7: closest beacon is at x=15, y=3";
x,:enlist"Sensor at x=14, y=3: closest beacon is at x=15, y=3";
x,:enlist"Sensor at x=20, y=1: closest beacon is at x=15, y=3";
line:10;

d15p1[line;x]   //26
d15p2[line;x]   //56000011

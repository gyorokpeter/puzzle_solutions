# Breakdown
Example input:
```q
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
```

## Part 1
We pull the useful numbers out of the input with some splitting and cleaning:
```q
q)a:"J"$2_/:/:(" "vs/:x except\:",:")[;2 3 8 9];
q)a
2  18 -2 15
9  16 10 16
13 2  15 3
12 14 10 16
10 20 10 16
..
```
We calculate the ranges of each scanner:
```q
q)range:sum each abs a[;0 1]-a[;2 3];
q)range
7 1 3 4 4 5 9 10 3 8 6 5 1 7
```
We check the length of the section of each scanner along the highlighted line. A negative number means the scanner doesn't reach the highlighted line.
```q
q)nr:range-abs line-a[;1];
q)nr
-1 -5 -5 0 -6 -2 6 0 2 4 -4 2 -6 -2
```
We find the sections on the highlighted line based on the ranges:
```q
q)xs:flip a[;0]+/:(neg nr;nr);
q)xs:asc xs where 0<=nr;
q)xs
-2 2
2  2
2  14
12 12
14 18
16 24
```
We merge the sections using the sweeping line algorithm - as they are ordered by their starting points, we check if the next one should be merged to it by comparing the starting point with the previous section's ending point.
```q
q)merged:{$[last[x][1]>=y[0];x[count[x]-1;1]|:y[1];x,:enlist y];x}/[1#xs;1_xs];
q)merged
-2 24
```
We calculate the total length of the covered area, but also subtract any beacons that we know are on the line within one of the covered sections:
```q
q)overlap:sum sum(distinct a[;2]where line=a[;3]) within/:merged;
q)overlap
1i
q)sum[1+merged[;1]-merged[;0]]-overlap
26
```

## Part 2
The calculation of `a` and `range` is as before. We also calculate `lim` as `2*line` just to be able to reuse the same size parameter as for Part 1.
```q
lim:2*line;
a:"J"$2_/:/:(" "vs/:x except\:",:")[;2 3 8 9];
range:sum each abs a[;0 1]-a[;2 3];
```
We reuse the logic from part 1 to calculate the coverage for an arbitrary line. One extra constraint is that we need to limit the sections to be between 0 and `lim`. We can then call this function on every possible value of `y`.
```q
    cover:{[a;range;lim;line]
        if[0=line mod 1000;show line];
        nr:range-abs line-a[;1];
        xs:flip a[;0]+/:(neg nr;nr);
        xs[;0]|:0; xs[;1]&:lim;
        xs:asc xs where 0<=nr;
        {$[last[x][1]>=y[0]-1;x[count[x]-1;1]|:y[1];x,:enlist y];x}/[1#xs;1_xs]
        }[a;range;lim]each til 1+lim;
```
The result is that all lines will have only a single section after the merge, but with a single excepion which has two sections, and that's the one we are looking for:
```q
c:where 2=count each cover;
```
The missing coordinate is one higher than the end of the first section:
```q
cc:1+cover[c;0;1];
```
Combined with the index where we found the odd one out, we can calculate the answer.
```q
c+4000000*cc
```

## Note
A suggestion on reddit that works with traditional languages is to walk around the perimeter of each square and check if each point is out of range of all the sensors. This only works because those languages don't have to keep all the candidate coordinates in memory at the same time. If we want to generate all those coordinates and then also check the distance to each of the sensors, we would hit the limit of the 32-bit memory space. Therefore it's simpler to stick with the slower line-by-line check.

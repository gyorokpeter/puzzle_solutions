LIMIT=1000000

t = int(input())
for tc in range(1, t + 1):
    colors = [[int(s) for s in input().split(" ")] for _ in range(3)]
    minColor = colors[0][:]
    for i in range(4):
        minColor[i] = min([minColor[i], colors[1][i], colors[2][i]])
    if sum(minColor) < LIMIT:
        r = "IMPOSSIBLE"
    else:
        rs = minColor[:]
        for i in range(1,4):
            rs[i] += rs[i-1]
            if rs[i] >= LIMIT:
                rs[i] = LIMIT
        for i in range(2,-1,-1):
            rs[i+1] = rs[i+1]-rs[i]
        r = " ".join(map(str,rs))
    print("Case #{}: {}".format(tc, r))

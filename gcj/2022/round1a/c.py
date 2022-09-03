t = int(input())
for tc in range(1, t + 1):
    e, w = [int(s) for s in input().split(" ")]
    ex = [[int(s) for s in input().split(" ")] for _ in range(e)]
    c = [e*[None] for _ in range(e)]
    for l in range(e):
        common = ex[l]
        total = sum(common)
        c[l][l] = total
        for r in range(l+1,e):
            thisEx = ex[r]
            delta = 0
            for wi in range(w):
                ds = -(common[wi]-thisEx[wi])
                if ds>0:
                    ds = 0
                common[wi] += ds
                delta += ds
            total += delta
            c[l][r] = total
    m = [e*[None] for _ in range(e)]
    for r in range(e):
        for l in range(r,-1,-1):
            if l==r:
                m[l][r] = 0
            else:
                m[l][r] = min([m[l][x]+m[x+1][r]+2*(c[l][x]+c[x+1][r]-2*c[l][r])for x in range(l,r)])
    r = m[0][e-1]+2*c[0][e-1]
    print("Case #{}: {}".format(tc, r))

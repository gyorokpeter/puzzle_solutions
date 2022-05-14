def verify(l):
    return sum(l)**2 == sum([x*x for x in l])

def sumOfPairwiseProducts(l):
    r = 0
    for i in range(len(l)):
        for j in range(i+1, len(l)):
            r += l[i]*l[j]
    return r

t = int(input())
for tc in range(1, t + 1):
    n, k = [int(s) for s in input().split(" ")]
    e = [int(s) for s in input().split(" ")]
    a = sum(e)
    b = sum([x*x for x in e])
    if k == 1:
        if a == 0:
            if b-a*a == 0:
                r = 0
            else:
                r = "IMPOSSIBLE"
        else:
            if (b-a*a) % (2*a) != 0:
                r = "IMPOSSIBLE"
            else:
                r = (b-a*a) // (2*a)
    else:
        n1 = 1-a
        n2 = -sumOfPairwiseProducts(e+[n1])
        r = "{} {}".format(n1, n2)
    print("Case #{}: {}".format(tc, r))

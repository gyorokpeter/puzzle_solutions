import sys

t = int(input())
for _ in range(t):
    n,k = [int(s) for s in input().split(" ")]
    degree = n * [-1]
    tdeg = []
    for i in range(k):
        wait = False
        r,p = [int(s) for s in input().split(" ")]
        degree[r-1] = p
        if 0 == i % 2:
            if i>=n:
                break
            print("T {}".format((i // 2)+1))
            sys.stdout.flush()
            wait = True
        else:
            tdeg.append(p)
            print("W")
            sys.stdout.flush()
            wait = True
    if wait:
        r,p = [int(s) for s in input().split(" ")]
        degree[r-1] = p
    missing = 0
    knownSum = 0
    for d in degree:
        if d == -1:
            missing += 1
        else:
            knownSum += d
    if missing == 0:
        print("E {}".format(knownSum//2))
        sys.stdout.flush()
    else:
        avgTdeg = sum(tdeg) / len(tdeg)
        estimate = knownSum+int(avgTdeg*missing)
        print("E {}".format(estimate//2))
        sys.stdout.flush()

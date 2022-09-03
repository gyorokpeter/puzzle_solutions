t = int(input())
for tc in range(1, t + 1):
    input()
    d = [int(s) for s in input().split(" ")]
    r = 0
    m = 0
    i = 0
    j = len(d)-1
    while i<=j:
        if d[i]<m:
            i+=1
        elif d[j]<m:
            j-=1
        elif d[i]<=d[j]:
            m = d[i]
            r += 1
            i += 1
        else:
            m = d[j]
            r += 1
            j -= 1
    print("Case #{}: {}".format(tc, r))

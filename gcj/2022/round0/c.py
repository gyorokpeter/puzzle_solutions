t = int(input())
for tc in range(1, t + 1):
    input() #n
    s = [int(x) for x in input().split(" ")]
    s.sort()
    l = 0
    for i in range(len(s)):
        if s[i] >= l+1:
            l += 1
    print("Case #{}: {}".format(tc, l))

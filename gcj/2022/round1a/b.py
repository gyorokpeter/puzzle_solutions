import sys

t = int(input())
LIMIT=10**9
for tc in range(t):
    n = int(input())
    nums = n*[0]
    c = 1
    for i in range(n):
        nums[i] = c
        nc = c*2
        c = nc if nc <= LIMIT else c+1
    print(" ".join(map(str,nums)))
    sys.stdout.flush()

    nums += [s for s in input().split(" ")]
    nums.sort()
    nums.reverse()
    r = []
    sa = 0
    sb = 0
    for num in nums:
        if sa < sb:
            sa += num
            r.append(num)
        else:
            sb += num
    print(" ".join(map(str,r)))

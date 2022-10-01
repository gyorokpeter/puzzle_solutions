import math

def filledCount(R):
    res=0
    for i in range(-R,R+1):
        res += math.floor(math.sqrt((R+0.5)*(R+0.5)-i*i))*2+1
    return res

s2=math.sqrt(2)

def perimeterCount(R):
    res=0
    for r in range(R+1):
        x1=math.floor(r/s2)
        y1=round(math.sqrt(r*r-x1*x1))
        x2=math.ceil(r/s2)
        y2=round(math.sqrt(r*r-x2*x2))
        x,y = (x2,y2) if x2<=y2 else (x1,y1)
        res += 2*x+1-(x==y)
    return 1+4*res

def solve(R):
    return filledCount(R)-perimeterCount(R)

t = int(input())
for tc in range(1, t + 1):
    r=int(input())
    print("Case #{}: {}".format(tc, solve(r)))

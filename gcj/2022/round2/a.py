t=int(input())
for tn in range(t):
    n,tlen=map(int,input().split())
    prefix="Case #{}: ".format(tn+1)
    if tlen<n-1 or 1==tlen%2:
        print(prefix+"IMPOSSIBLE")
        continue
    rings=n//2
    cring=rings
    short=[]
    toSave=(n*n-1)-tlen
    while toSave>0:
        upperLeft=n*n-4*cring*(cring+1)
        upperLeftNext=n*n-4*cring*(cring-1)
        maxSave=cring*8-2
        minSave=(cring-1)*8
        if toSave>maxSave:
            toSave-=maxSave
            short.append((upperLeft+cring,upperLeftNext+cring-1))
        elif toSave>=minSave:
            steps=3-(toSave-minSave)//2
            toSave=0
            short.append((upperLeft+cring*(1+2*steps),upperLeftNext+(cring-1)*(1+2*steps)))
        cring-=1
    print(prefix+str(len(short)))
    [print("{} {}".format(*x)) for x in short]

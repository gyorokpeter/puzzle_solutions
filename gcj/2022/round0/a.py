t = int(input())
for tc in range(1, t + 1):
    r,c = [int(s) for s in input().split(" ")]
    print("Case #{}:".format(tc))
    sep1 = ".."+("+-"*(c-1))+"+"
    row1 = ".."+("|."*(c-1))+"|"
    sep = "+-"+sep1[2:]
    row = "|."+row1[2:]
    rows = [sep1,row1]+([sep,row]*(r-1))+[sep]
    [print(x) for x in rows]

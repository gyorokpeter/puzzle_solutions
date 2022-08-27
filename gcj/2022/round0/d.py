def fun(graph, parents, minPaths, funs, node):
    children = graph[node]
    if 0 == len(children):
        return funs[node]
    pathNode, pathFun = minPaths[node]
    branchFun = 0
    while True:
        prevPathNode = pathNode
        pathNode = parents[pathNode]-1
        branchFuns=[fun(graph, parents, minPaths, funs, x) for x in graph[pathNode] if x != prevPathNode]
        branchFun += sum(branchFuns)
        if pathNode == node:
            break
    return pathFun+branchFun

t = int(input())
for tc in range(1, t + 1):
    n = input()
    funs = [int(s) for s in input().split(" ")]
    parents = [int(s) for s in input().split(" ")]
    n = len(funs)
    graph = [[] for _ in range(n)]
    for i in range(len(parents)):
        p = parents[i]
        if p>0:
            graph[p-1].append(i)
    minPaths=[[] for _ in range(n)]
    for x in range(n-1, -1, -1):
        mink = x
        minv = funs[x]
        if 0<len(minPaths[x]):
            mink = -1
            minv = -1
            for (k,v) in minPaths[x]:
                if mink == -1 or v < minv:
                    mink, minv = k, v
            minv = max(funs[x], minv)
        minPaths[x] = (mink, minv)
        if parents[x]>0:
            minPaths[parents[x]-1].append((mink, minv))
    r=sum([fun(graph, parents, minPaths, funs, x) for x in range(n) if parents[x] == 0])
    print("Case #{}: {}".format(tc, r))

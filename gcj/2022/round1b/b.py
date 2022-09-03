import heapq as hq
import math

def dijkstra(G, s):
    n = len(G)
    visited = [False]*n
    weights = [math.inf]*n
    path = [None]*n
    queue = []
    weights[s] = 0
    hq.heappush(queue, (0, s))
    while len(queue) > 0:
        g, u = hq.heappop(queue)
        visited[u] = True
        for v, w in G[u]:
            if not visited[v]:
                f = g + w
                if f < weights[v]:
                    weights[v] = f
                    path[v] = u
                    hq.heappush(queue, (f, v))
    return path, weights

t = int(input())
for tc in range(1, t + 1):
    n,p = [int(s) for s in input().split(" ")]
    lows = n*[0]
    highs = n*[0]
    for i in range(n):
        ps = [int(s) for s in input().split(" ")]
        lows[i] = min(ps)
        highs[i] = max(ps)
    #nodes: n+2
    #edges: 2 from start to [0], 2 from [n-1] to target, 4 between consecutive node pairs - n*4 total
    graph = []
    #start->up, start->down
    graph.append([(1,lows[0]), (2,highs[0])])
    for i in range(n-1):
        curr = highs[i]-lows[i]
        #up->up, up->down
        graph.append([(2*i+3,curr+abs(highs[i]-lows[i+1])),(2*i+4,curr+abs(highs[i]-highs[i+1]))])
        #down->up, down->down
        graph.append([(2*i+3,curr+abs(lows[i]-lows[i+1])),(2*i+4,curr+abs(lows[i]-highs[i+1]))])
    #up->end
    curr = highs[-1]-lows[-1]
    graph.append([(2*n+1,curr)])
    #down->end
    graph.append([(2*n+1,curr)])
    graph.append([])

    r = dijkstra(graph, 0)[1][-1]

    print("Case #{}: {}".format(tc, r))

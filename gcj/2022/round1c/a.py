def isValidWord(word):
    cs = set(word[0])
    for i in range(1,len(word)):
        if word[i] != word[i-1]:
            if word[i] in cs:
                return False
            else:
                cs.add(word[i])
    return True

def solve(s):
    single = {}
    doubleStart = {}
    doubleEnd = {}
    for word in s:
        if not isValidWord(word):
            return "IMPOSSIBLE"
        if word[0] == word[-1]:
            if word[0] in single:
                single[word[0]] += word
            else:
                single[word[0]] = word
        else:
            if word[0] in doubleStart:
                return "IMPOSSIBLE"
            else:
                doubleStart[word[0]] = word
            if word[-1] in doubleEnd:
                return "IMPOSSIBLE"
            else:
                doubleEnd[word[-1]] = word
    r = ""
    while 0<len(doubleStart):
        st = ""
        for word in doubleStart.values():
            if not word[0] in doubleEnd:
                st = word
                break
        if st == "":
            return "IMPOSSIBLE"
        del doubleStart[st[0]]
        del doubleEnd[st[-1]]
        if st[0] in single:
            st = single[st[0]] + st
            del single[st[0]]
        if st[-1] in single:
            st = st + single[st[-1]]
            del single[st[-1]]
        while st[-1] in doubleStart:
            word = doubleStart[st[-1]]
            st += word
            del doubleStart[word[0]]
            del doubleEnd[word[-1]]
            if st[-1] in single:
                st += single[st[-1]]
                del single[st[-1]]
        r += st
    r = r + "".join(single.values())
    if not isValidWord(r):
        return "IMPOSSIBLE"
    return r

t = int(input())
for tc in range(1, t + 1):
    input()
    s=input().split(" ")
    r=solve(s)
    print("Case #{}: {}".format(tc, r))

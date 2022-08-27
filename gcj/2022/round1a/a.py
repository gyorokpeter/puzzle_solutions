t = int(input())
for tc in range(1, t + 1):
    s = input()
    r = ""
    run = 1
    for i in range(len(s)-1):
        if s[i] != s[i+1]:
            if ord(s[i]) < ord(s[i+1]):
                run *= 2
            r += run*s[i]
            run = 1
        else:
            run += 1
    r += s[-run:]
    print("Case #{}: {}".format(tc, r))

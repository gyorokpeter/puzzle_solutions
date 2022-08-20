MOD=1000000007

def egcd(a, b):
    if a == 0:
        return (b, 0, 1)
    else:
        g, y, x = egcd(b % a, a)
        return (g, x - (b // a) * y, y)

modinvCache={}

def modinv(a):
    global modinvCache
    if a in modinvCache:
        return modinvCache[a]
    g, x, y = egcd(a, MOD)
    if g != 1:
        raise Exception('modular inverse does not exist')
    else:
        result = x % MOD
        modinvCache[a] = result
        return result

p = False

t = int(input())
for tc in range(1, t + 1):
    m, k = [int(s) for s in input().split(" ")]
    edges = m*(m-1)//2

    f = 0
    gdenom=1
    for j in range(1, k):
        a = m-2*j
        gdenom = (gdenom*(m*(m-1)-a*(a-1))//2)%MOD
    twos = 2**(k-1)
    mmti = 1
    for s in range(m-2*(k-1)+1,m+1):
        mmti = mmti*s%MOD
    flow = False
    combs = 1

    for i in range(k, m//2+1):
        a = m-2*i
        gdenom = gdenom*(m*(m-1)//2-a*(a-1)//2)%MOD
        twos = twos*2%MOD
        mul1 = (m-2*i+1)
        mul2 = (m-2*i+2)
        mmti = mmti*(mul1*mul2)%MOD
        gfull0 = (gdenom*twos)%MOD
        gfull = (mmti%MOD)*modinv(gfull0)%MOD
        flow = not flow
        if i>k:
            combs = (combs*i*modinv(i-k))%MOD
        fa = combs
        fb = (gfull.numerator%MOD)*modinv(gfull.denominator)%MOD
        f = (f+fa*fb if flow else f-fa*fb)%MOD
    r = f

    print("Case #{}: {}".format(tc, r))

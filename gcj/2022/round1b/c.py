import sys

#these are just copied out of the analysis
def appendzero(s):
  return s + '0' * len(s)

def expand(s):
  return s + s

def P(k):
  if k == 0:
      return ['1']
  seq = P(k - 1)
  seq_with_zero = [appendzero(s) for s in seq]
  seq_with_copy = [expand(s) for s in seq]
  res = seq_with_copy[:]
  for ins in seq_with_zero:
      res += [ins]
      res += seq_with_copy
  return res

guesses = P(3)
t = int(input())
for _ in range(t):
    for guess in guesses:
        print(guess)
        sys.stdout.flush()
        n = int(input())
        if n == 0:
            break
        elif n == -1:
            exit(1)

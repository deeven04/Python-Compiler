def Fibonacci(n):
  if n<= 0:
    print("Incorrect input")
    return 0 
  elif n == 1:
    return 0
  elif n == 2:
    return 1
  else:
    return Fibonacci(n - 1) + Fibonacci(n - 2)


def fibonacci(n):
  a = 0
  b = 1
  if n < 0:
    print("Incorrect input")
  elif n == 0:
    return a
  elif n == 1:
    return b
  else:
    return 0
  for i in range(2, n):
    c = a + b
    a = b
    b = c
    return b

def main():
  x = fibonacci(10)
  y = Fibonacci(10)
  if x == y:
    print("Both fibonacci's matched")
  x = fibonacci(10)
  y = Fibonacci(10)
  if x == y:
    print("Both fibonacci's matched")

if __name__ == "__main__":
    main()

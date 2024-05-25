def is_palindrome(s): 
  i = 0
  j = len(s) - 1
  while i < j:
    if s[i] != s[j]:
      return False
      i += 1
      j -= 1
  return True

def factorial(n):  
  if n == 0:
    return 1
  else:
    return n * factorial(n - 1)

def main():
    n = 121  
    result = factorial(n)
    print(f"The factorial of {n} is {result}")
 
    factorial_str = str(result)
    
    if is_palindrome(factorial_str):
        print(f"The factorial of {n} ({result}) is a palindrome.")
    else:
        print(f"The factorial of {n} ({result}) is not a palindrome.")


    factorial_sum = sum(map(int, str(result)))
    print(f"The sum of digits in the factorial of {n} is {factorial_sum}")

if __name__ == "__main__":
    main()

def binarySearch(array: list[int], x: int, low: int, high: int) -> int:
  while low <= high:
    mid: int = low + (high - low) // 2
    if array[mid] == x:
      return mid
    elif array[mid] < x:
      low = mid + 1
    else:
      high = mid - 1
  return -1


def main():
  array2:list[int] = [3, 4, 5, 6, 7, 8, 9]
  result:int = binarySearch(array2, 4, 0, len(array2) - 1)

  if result != -1:
    print("Element is present at index:")
    print(result)
  else:
    print("Element is not present")


if __name__ == "__main__":
  main()

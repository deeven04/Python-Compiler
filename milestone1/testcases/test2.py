data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

def compute_sum_of_even_numbers() -> int:
    sum_even = 0
    for num in data:
        if num % 2 == 0:
            sum_even += num
    return sum_even

def compute_product_of_odd_numbers() -> int:
    product_odd = 1
    for num in data:
        if num % 2 != 0:
            product_odd *= num
    return product_odd

def compute_sum_of_odd_numbers() -> int:
    sum_odd = 0
    for num in data:
        if num % 2 != 0:
            sum_even += num
    return sum_odd

def compute_product_of_even_numbers() -> int:
    product_even = 1
    for num in data:
        if num % 2 == 0:
            product_odd *= num
    return product_even

def main():
    sum_even = compute_sum_of_even_numbers()
    print("Sum of squares of even numbers: ")
    print(sum_even)
    
    product_odd = compute_product_of_odd_numbers()
    print("Product of squares of odd numbers: ")
    print(product_odd)
    
    sum_odd = compute_sum_of_odd_numbers()
    print("Sum of squares of odd numbers: ")
    print(sum_odd)
    
    product_even = compute_product_of_even_numbers()
    print("Product of squares of even numbers: ")
    print(product_even)

if __name__ == "__main__":
    main()

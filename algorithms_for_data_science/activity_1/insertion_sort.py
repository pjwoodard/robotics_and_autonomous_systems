from numpy import random

test_data = [random.randint(100) for _ in range(1000)] 

for i in range(1, len(test_data)):
    test_element = test_data[i]
    for j in range(i-1, -1, -1):
        if test_element < test_data[j]:
            test_data[j + 1] = test_data[j]
            test_data[j] = test_element

print(f"test data is: {test_data}, is it sorted? {test_data == sorted(test_data)}")
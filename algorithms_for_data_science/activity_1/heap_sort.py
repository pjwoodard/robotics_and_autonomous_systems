import math
from numpy import random
from typing import List

def left_child(node_id: int):
    return (2 * node_id) + 1

def right_child(node_id: int):
    return (2 * node_id) + 2

def parent(node_id: int):
    return math.floor((node_id - 1) / 2)

def heapify(data: List[int], data_size: int, root_id: int):
        # Save each node as a tuple of (value, list index)
        root = (data[root_id], root_id)
        left = () 
        right = () 

        if left_child(root_id) < data_size:
            left = (data[left_child(root_id)], left_child(root_id))
        if right_child(root_id) < data_size:
            right = (data[right_child(root_id)], right_child(root_id))

        # Grab the max of the root, its left child, and its right child
        max_node = max(root, left, right)

        # Swap root with the max child using our saved tuple index to help us out
        # If the parent is not the max node, we don't need  to swap anything
        if root_id != max_node[1]:
            data[root_id], data[max_node[1]] = data[max_node[1]], data[root_id]

            # Recursive call to keep heapifying if root was not the largest
            heapify(data, data_size, max_node[1])


# test_data = [1, 12, 9, 5, 6, 10]
test_data = [random.randint(100) for _ in range(20)] 

# Build ourselves a max heap by calling heapify (max) from the bottom up
for i in range(int(len(test_data) / 2) - 1, -1, -1):
    heapify(test_data, len(test_data), i)

# Heap sort, sorts list in place
def heap_sort(data: List[int]):
    # Do the sorting
    for i in range(len(data) - 1, 0, -1):
        data[i], data[0] = data[0], data[i]

        heapify(data, i, 0)

# Sort data
heap_sort(test_data)

# Check if data is sorted
print(f"Sorted? {test_data == sorted(test_data)}")

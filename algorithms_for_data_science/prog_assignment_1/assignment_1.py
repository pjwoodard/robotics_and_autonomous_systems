import statistics
import math
import unittest

from typing import List

# No need to import scipy for this, we just calculate it here the same way scipy does with less features :) 
# https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.trim_mean.html
def trim_mean(data: List[int], percentage_to_trim: float) -> List[int]:
    # Sort the data first
    data.sort()

    # We default to scipy's decision to take the floor of the percentage of data to trim from either side
    # https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.trimboth.htmlA
    amount_to_trim = math.floor(len(data) * percentage_to_trim)
    print(amount_to_trim)

    # Cut off a percentage of the data from both sides 

    statistics.mean(data)

class TestTrimMean(unittest.TestCase):
    def test_trim_mean(self):
        self.assertEqual(trim_mean([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], 0.1), 5.5)
        self.assertEqual(trim_mean([10, 20, 30, 40, 50, 60, 70, 80, 90, 100], 0.2), 55.0)
        self.assertEqual(trim_mean([1, 1, 1, 1, 1, 1, 1, 1, 1, 1], 0.1), 1.0)
        self.assertEqual(trim_mean([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], 0.2), 5.5)

    def test_empty_list(self):
        with self.assertRaises(ValueError):
            trim_mean([], 0.1)

    def test_invalid_percentage(self):
        with self.assertRaises(ValueError):
            trim_mean([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], -0.1)
        with self.assertRaises(ValueError):
            trim_mean([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], 1.1)

if __name__ == '__main__':
    unittest.main()

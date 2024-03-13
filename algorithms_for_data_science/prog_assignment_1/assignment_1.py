# import iris data set
from itertools import combinations
import time
import seaborn
import functools
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy import stats 
from sklearn import datasets
from heap_sort import heap_sort
from sklearn.decomposition import PCA

def timer(func):
    @functools.wraps(func)
    def wrapper_timer(*args, **kwargs):
        tic = time.perf_counter()
        value = func(*args, **kwargs)
        toc = time.perf_counter()
        elapsed_time = toc - tic
        print(f"Elapsed time: {elapsed_time:0.4f} seconds")
        return value
    return wrapper_timer

# Load the iris data set
iris_data = datasets.load_iris()

def iris_statistics():
    # Loop through each class and through each feature in that class
    for target in range(len(iris_data.target_names)):
        print(f"Class: {iris_data.target_names[target]}")
        class_data = iris_data.data[iris_data.target == target]
        data_as_array = np.array([
            class_data.min(axis=0).tolist(), 
            class_data.max(axis=0).tolist(),
            class_data.mean(axis=0).tolist(),
            class_data.std(axis=0).tolist(),
            stats.trim_mean(class_data, 0.1, axis=0).tolist(),
            stats.trim_mean(class_data, 5/len(class_data), axis=0).tolist(),
            stats.skew(class_data, axis=0).tolist(),
            stats.kurtosis(class_data, axis=0).tolist()
        ])

        # Labels for our rows and columns
        columns = [feature_name for feature_name in iris_data.feature_names]
        rows = ['Min', 'Max', 'Mean', 'Standard Deviation', 'Trimmed Mean', 'Alpha Trimmed Mean', 'Skewness', 'Kurtosis']

        # Convert the NumPy array to a DataFrame with row and column labels for nice formatting
        df = pd.DataFrame(data_as_array, index=rows, columns=columns)
        print(df)

# iris_statistics()

# We can make the following conclusions from the data

# Sepal Length and Width
    # The sepal lengths and widths vary across the different classes, with virginica generally having the longest sepals and setosa the shortest.
    # Setosa has the widest sepals on average, virginica and versicolor have similar widths.
# Petal Length and Width
    # Petal lengths and widths show the most significant differences among the classes.
    # Setosa has the shortest and narrowest petals, while virginica has the longest and widest.
    # Versicolor falls between setosa and virginica in terms of petal size, but its petals are closer in size to virginica.
# Distribution Statistics
    # The mean, trimmed mean, and alpha trimmed mean provide different ways to estimate the central tendency of the data, with the trimmed and alpha trimmed means being less sensitive to outliers.
    # Skewness measures the symmetry of the distribution. Positive skewness indicates a longer tail on the right, while negative skewness indicates a longer tail on the left.
    # Kurtosis measures the "peakedness" of the distribution. Higher kurtosis indicates a more peaked distribution, while lower kurtosis indicates a flatter distribution.
# Overall Analysis
    # The differences in means, standard deviations, skewness, and kurtosis suggest that the classes are distinct in terms of these features.
    # These differences can be used to classify iris flowers based on their sepal and petal measurements.

def seaborn_plots():
    df = seaborn.load_dataset("iris")
    subset_df = df[["sepal_length", "sepal_width", "species"]]
    seaborn.pairplot(subset_df, hue="species")
    plt.show()
# seaborn_plots()

@timer
def sort_iris_data():
    for target in range(len(iris_data.target_names)):
        print(f"Class: {iris_data.target_names[target]}")
        for feature in range(len(iris_data.feature_names)):
            data_copy = iris_data.data[iris_data.target == target][:, feature].copy()
            heap_sort(data_copy)
            print(data_copy)
sort_iris_data()

# Total Runtime Complexity:
# Big O notation: O(n * log(n))
# Big Omega notation: Ω(n * log(n))
# Big Theta notation: Θ(n * log(n))
# Clock time (sort all features ): ~0.0022 seconds
# Explanation:
#   * Our first step is to make sure that our data is structured as a max heap 
#   * Our first loop builds our max heap by calling heapify for each element in our list, heapify is log(n) and we have n elements
#   * Heapify runs at most log(n) operations as it only does O(1) operations per level of tree transversal so the number of operations is proportional to tree height
#   * For each element in our max heap we swap the current root (max element) with the last element in our array and call heapify on the new root to maintain our max heap
#   * We end up with our largest elements at the end of the array and the smallest elements at the beginning, meaning our array is sorted

# None of the four features can separate all three of the plant species. While some species had a set of features that were disjoint, at least two of the species overlapped for 
# each feature.
# The metric chosen for separation was by treating each feature as a set and checking if, for each feature, there was intersection between the sets of the three species.
# If one of the species had a set that was entirely disjoint, we know that feature can separate the species. 

def min_max_norm(data):
    min_val = min(data)
    max_val = max(data)
    return [(x - min_val) / (max_val - min_val) for x in data]

def normalize_iris_data():
    for feature in range(len(iris_data.feature_names)):
        print(iris_data.feature_names[feature])
        print(min_max_norm(iris_data.data[:, feature]))

# normalize_iris_data()

def mahalanobis_distance(sample, mean_vector, cov):
    """
    Calculates the Mahalanobis distance between two vectors. 
    Uses the following formula: D^2 = (u - v)^T * cov^-1 * (u - v)
    """
    # Calculate the difference between the vectors.
    diff = sample - mean_vector # O(1)
    # Calculate the dot product of the difference and the inverse of the covariance matrix.
    dot = np.dot(diff.T, cov) # O (n^2) probably
    # Calculate the Mahalanobis distance by taking the square root of the dot product of the difference and the inverse of the covariance matrix.
    md = np.sqrt(np.dot(dot, diff)) # O(n^2) + O(1) = O(n^2)
    return md

@timer
def outlier_removal_iris_data():
    for target in range(len(iris_data.target_names)):
        print(f"Class: {iris_data.target_names[target]}")
        class_data = iris_data.data[iris_data.target == target]
        # Calculate the mean and covariance matrix for the class data.
        mean_vector = np.mean(class_data, axis=0)
        cov = np.cov(class_data.T)
        # Calculate the Mahalanobis distance for each sample in the class data.
        md = [mahalanobis_distance(sample, mean_vector, cov) for sample in class_data]
        print(f"distance: {md}")
        heap_sort(md)
        print(f"sorted distance: {md}")
        # Sort the Mahalanobis distances and remove the furthest sample from the class data.
        class_data = np.delete(class_data, np.argmax(md), axis=0)

# outlier_removal_iris_data()

# Total Runtime Complexity:
# Big O notation: O(n^2)
# Big Omega notation: Ω(n^2)
# Big Theta notation: Θ(n^2)
# Clock time (Calculate mahalanobis distance on all features of all three classes): ~0.0019 seconds

# Some classes had obvious outliers such as virginica followed by versicolor, and finally setosa. 
# We determined the outliers by calculating the Mahalanobis distance for each sample in the class data. We then sorted the 
# distances to easily identify the furthest samples from the class data.

# Insprired by data processing (activity 3)
@timer
def fisher_multi_class_feature_ranking():
    y = iris_data.target
    x = iris_data.data
    classes = np.unique(y) # O(n log n)
    ranking = {} # Results

    def get_fdr(x, y, classes):
        x_1, x_2 = x[np.where(y == classes[0])], x[np.where(y == classes[1])] # O(n)
        mu_1 = np.mean(x_1, axis=0) # O(n)
        mu_2 = np.mean(x_2, axis=0) # O(n)
        sigma_1_sq = np.std(x_1, axis=0) ** 2 # O(n)
        sigma_2_sq = np.std(x_2, axis=0) ** 2 # O(n)
        fdr = (mu_1 - mu_2) ** 2 / (sigma_1_sq + sigma_2_sq) # O(n)
        return fdr

    # We are only handling the multicase scenario in this function
    if(len(classes) >= 3):
        combs = list(combinations(classes, 2)) # O(n choose k)
        arr = np.zeros((len(combs), x.shape[1])) 
        for index, comb in enumerate(combs): # O(n)
            element = list(comb)
            arr[index, :] = get_fdr(x, y, element) # O(n)

        def avg_minus_min_max(arr, axis=0):
            return np.mean(arr, axis=axis) - (np.max(arr, axis=axis) + np.min(arr, axis=axis)) / 2

        fdr_results = avg_minus_min_max(arr, axis=0)
        print(fdr_results)
        for idx, x in enumerate(np.argsort(fdr_results)[::-1]):
            ranking[f"feature_{x+1}"] = idx + 1 
    
    return ranking

print(fisher_multi_class_feature_ranking())

# Total Runtime Complexity:
# Big O notation: O(n)
# Big Omega notation: Ω(n)
# Big Theta notation: Θ(n)
# Clock time (FDR on all features of all three classes): ~0.0003 seconds
# Assumed some of the running times of numpy algorithms based on how I think they work
# Given that our longest running time operations O(n log n) / O(n choose k) are run on incredibly small sets 
# of data, we can assume that the running time is O(n) for the entire function
# Using the results of the FDR, it seems that features 3 and 4 are the most important for separating the classes.
# I'm not sure how to decide, given the FDR values, if a feature completely separates the three plant types but you
# can draw conclusions about which feature is most useful for distinguishing between the classes. 
# A metric can be developed to complement the ranking method. You can choose a threshold value for the FDR to be able 
# to choose a feature for separation.

def pca_analysis():
    pca_total = PCA(n_components=4)
    pca_total.fit(iris_data.data)
    print(f"Variance ratio (Total Dataset): {pca_total.explained_variance_ratio_}")
    print(f"PCA values (Total Dataset): {pca_total.singular_values_}")
    for target in range(len(iris_data.target_names)):
        class_data = iris_data.data[iris_data.target == target]
        pca_by_class = PCA(n_components=4)
        pca_by_class.fit(class_data)
        print(f"Variance ratio ({iris_data.target_names[target]} Dataset): {pca_by_class.explained_variance_ratio_}")
        print(f"PCA values ({iris_data.target_names[target]} Dataset): {pca_by_class.singular_values_}")

# pca_analysis()

# The percentage explained for each pricipal component represents the amount of variance that is captured by each component. 
# When using all of the data, the first principal component captures more of a share of the variance than when using individual classes of data.
# The higher the percentage explained by a component the more important it is when describing the underlying data
# Typically you want to keep enough principal components to explain a significant portion of the variance while reducing the dimensionality
# of your data
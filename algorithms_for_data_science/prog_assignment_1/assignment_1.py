# import iris data set
import time
import seaborn
import functools
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy import stats 
from sklearn import datasets
from heap_sort import heap_sort
from sklearn.model_selection import train_test_split
from sklearn.pipeline import make_pipeline
from sklearn.decomposition import PCA
from sklearn.preprocessing import MinMaxScaler

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
# sort_iris_data()

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

# (e) Feature Ranking [10 points]
# i. Design an algorithm (pseudocode) to rank the four features in the Iris dataset.
# ii. Provide the running time and total running time of your algorithm in O-notation and
# T(n). State any assumptions you made in your breakdown.
# iii. Implement your design, recommended to create a class for future use. The use of a
# built in function is not authorized for this.
# iv. Determine if any of the four features can separate the three plant types.
# v. Provide an explanation of the results:
# 3
# A. Was there any feature that could separate the data by plant species; if so why, if
# not why not?
# B. If a feature could not separate the plant types; what conclusion can drawn from
# this feature?
# C. Can a metric be developed to complement the ranking method? Explain why or
# why not.


# (f) Principal Component Analysis (PCA) [10 points]
# i. Use the built-in PCA to perform analysis of the Iris data set using all species (classes).
# ii. Use the built-in PCA to perform analysis of the Iris data set by specie (class).
# iii. Provide an explanation of the results:
# A. What is the difference between using all the data and using the data by specie
# (class)?
# B. what is the percentage explained for each principal component?
# C. how many principal components should you keep?

def pca_analysis():
    X_train, X_test, y_train, _ = train_test_split(iris_data.data, iris_data.target, test_size=0.2, random_state=42)
    
    # Create a preprocessing pipeline with at least two processing steps
    preprocessing_pipeline = make_pipeline(
        # Add a StandardScaler step to the pipeline
        MinMaxScaler(),
        # Add a PCA step to the pipeline
        PCA(n_components=3)
    )

    preprocessing_pipeline.fit(X_train, y_train)
    samples = preprocessing_pipeline.transform(X_test)
    print(samples)

pca_analysis()
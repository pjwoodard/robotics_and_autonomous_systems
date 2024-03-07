# import iris data set
from scipy import stats 
from sklearn import datasets
import pandas as pd
import numpy as np

# Load the iris data set
iris = datasets.load_iris()

# Loop through each class and through each feature in that class
for target in range(len(iris.target_names)):
    print(f"Class: {iris.target_names[target]}")
    class_data = iris.data[iris.target == target]
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
    columns = [feature_name for feature_name in iris.feature_names]
    rows = ['Min', 'Max', 'Mean', 'Standard Deviation', 'Trimmed Mean', 'Alpha Trimmed Mean', 'Skewness', 'Kurtosis']

    # Convert the NumPy array to a DataFrame with row and column labels for nice formatting
    df = pd.DataFrame(data_as_array, index=rows, columns=columns)
    print(df)

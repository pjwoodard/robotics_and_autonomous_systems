from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import MinMaxScaler
from sklearn.decomposition import PCA

# Load the Iris dataset
iris = load_iris()
X = iris.data  # Features
y = iris.target  # Target labels

# Perform an 80-20 train-test split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Print the shapes of the resulting sets to verify the split
print("X_train: ", X_train)
print("Y_train: ", y_train)
print("X_test: ", X_test)
print("Y_test: ", y_test)   
print("X_train shape:", X_train.shape)
print("X_test shape:", X_test.shape)
print("y_train shape:", y_train.shape)
print("y_test shape:", y_test.shape)

# Create a preprocessing pipeline with at least two processing steps
preprocessing_pipeline = make_pipeline(
    # Add a StandardScaler step to the pipeline
    MinMaxScaler(),
    # Add a PCA step to the pipeline
    PCA(n_components=X_train.shape[1])
)

# Mahalanobis Distance for Outlier Removal

preprocessing_pipeline.fit(X_train, y_train)
samples = preprocessing_pipeline.transform(X_test)
print(samples)

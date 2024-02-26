

# 1. The plots down the diagonal show univariate distribution plots drawn to show the marginal distribution of the data in each column
# 2. No feature separates the three classes completely, but petal width shows the most separation of the 4 features.
# 3. There is no combination of features that completely separates the three class, it looks like petal_width x petal_length comes the closest (to my eye).


# # References
# e1] https://seaborn.pydata.org/generated/seaborn.pairplot.html#seaborn.pairplot

import seaborn as sns
sns.set_theme(style="ticks")

df = sns.load_dataset("iris")
sns.pairplot(df, hue="species")
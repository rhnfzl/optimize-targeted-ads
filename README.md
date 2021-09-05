## Optimizing Streaming Service Targeted Ads using Neural Network model and Multiple Linear Regression Model

### Goal

To optimize streaming service ads to increase marketing campaign efforts with targeted ads and price structure. The data collected are from the previous subscription cycle and third party providers which has the 14 explanatory variables (features) and one outcome variable. The outcome variable shows the historical result whether the customer continues their subscription or not in the next subscription cycle.

asks are:

- Build a Neural Network model to predict if a customer will continue their subscription or not. Select any and as many variables as the predictors and calculate the accuracy, sensitivity, and specificity of your prediction model and discribe the focus of the target ads with the customer with a high probability of continuing the subscription or those who have a smaller probability

- Using the same set of features as used above, build a multiple linear regression model. 

- Compare both the model about it's accuracy, sensitiveness, and specificicity

### Setup

Use the R-Studio

#### Library Used

- tidyverse
- tidymodels
- neuralnet
- e1071
- fpp2
- corrplot
- mgcv
- caret

```install.packages(c("tidyverse", "e1071", "fpp2", "corrplot", "mgcv", "caret", "tidymodels", "neuralnet"))```

### Implementation

#### Dataset
The data has 16 named attributes (one extra unnamed attribute) in total, out which 14 are explanatory variables (features) and one outcome variable. The explanatory attributes consist of data gathered from third party source too.

- ```customer_id``` : Customer ID.
- ```cont_subs``` : Result of previous subscription cycle (Outcome Variable).
- ```sex``` : Third party data, identified gender.
- ```counties``` : Counties of California state.
- ```series_hour``` : Watch hour of TV series per month. Measured in Hours.
- ```movie_hour``` : Watch hour of Movies per month. Measured in Hours.
- ```age``` : Collected during sign-up. Measured in number of years.
- ```watch_medium``` : Type of interface used to consume media content. 
- ```household``` : Third party data, identified household.
- ```gift``` : State of previous subscription is a gift.
- ```income``` : Third party data, predicted income. Calculated USD per Month.
- ```cont_watch``` : Watch hours on average per session. Measured in Hours.
- ```dear_john``` : Ratings given to the movie "Dear John" on the scale of 1 to 5.
- ```genre``` : Most often genre watched.
- ```facebook_lean``` : Third party data, indicates  political lean.
- ```diehard``` : Watched or rate any of the "Diehard" movies.

As from the description above, it can be seen that there are four features which are collected from the Third-party, the rest of the features are collected during sign-up or during the usage.


#### Data Wrangling
Following transformations were applied over provided dataset:

- After reading the dataset, observed that one of the attributes is unnamed, so removed it while reading it.
- From the summary of dataset found out that ```dear_john``` is numerical, so converted it to the character using mutate ```as.character()```.
- As per lecture, need to split the data randomly in 80:20 ratio, i.e. 80\% for training and 20% for testing.
- Then the randomly selected data has to be built for several train and test based on the features selected for respective undermentioned neural networks model. Since categorical variables cannot be directly fed to neural nets, it has to be changed to numerical values using one-hot encoding, and existing numerical values need to be centred and normalized. Both have been done for respective train and test datasets.

#### Neural Network

##### Feature Relation

Correlation measure of the features are done in shown in below figure is to optimize the selection of the features used for modeling. A strong correlation between the new feature and an existing feature is a fairly good sign that there is little new information in the new feature. A low correlation between the new feature and existing features is likely preferable.

![featurescorrelation](/img/featurescorrelation.png)

##### Modelling

Model I : This model is the most accurate overall. A few of the features have far too many values to be effective like : ```counties```, ```dear_john``` and ```diehard```  has been removed from the model.  Apart from it, it does not use the ```facebook_lean``` which is the Third-party feature. So, in total, this model considers ten features. The number of the hidden layer (neurons) used is 6 in this case. The below figure depicts the neural network of the model.

![nnmodel2](/img/nnmodel2.png)

The accuracy of the above model is ```97.36%```, Sensitivity is ```97.78%```, and Specificity is ```96.36%```.

![confusionmatrix1](/img/confusionmatrixm2.png)

Model II : This model is fastest and models within the accuracy threshold as compared to other Neural Network Model which has been tested, Just like Model-I it does not consist of features like: ```counties```, ```dear_john``` and ```diehard``` for the reason as mentioned earlier. Also, the features do not consist of any Third Party data (```sex```, ```household```, ```income```, ```facebook_lean```), which makes it interesting and privacy centric. The feature list consist of only $series\_hour$, ```movie_hour```, and ```genre```.  So, in total, this model considers only three features which consumers generally give consent to be used by the streaming company. The feature selection was achieved using the correlation matrix described above and bit of hit and trial method. The number of the hidden layer (neurons) used is 2 in this case. The below figure depicts the neural network model.

![nnmodel1](/img/nnmodel1.png)

The accuracy of the above model is ```96.09%```, Sensitivity is ```96.81%```, and Specificity is  ```94.32%```.

![confusionmatrix2](/img/confusionmatrixm1.png)


Considering all the factors derived from the Neural Network model, i.e., Model-II, the significant features which affect the decision to continue the subscription is quite evident. The streaming company should focus on Genre and understand its role in Movie and Series watch time, but the data which will be available for new customer and old customer will significantly change the decision. Though in the dataset it is not provided if the customer is new or the old. 


The streaming company can create more compelling services using Model-II features by offering better-personalized recommendations, which will elicit customers to stay longer and improve retention. All customers with an improved experience (not only those on the fence) can be more positive when explaining streaming content to their friends and families, providing a significant impact on potential user growth via word-of-mouth results. Both the recall of a better experience and more reliable word-of-mouth can influence former customers to rejoin more quickly. The analogy is backed up by the [The Netflix Recommender System: Algorithms, Business Value, and Innovation](https://dl.acm.org/doi/10.1145/2843948) research.

Having said that, this will give streaming service companies more control over both the continuing and non-continuing customers. In my opinion, targeted ads and competitive subscription fees could be more focused on the customer who is more likely to continue the subscription.

#### Multiple Linear Regression Model

The R-Square value of the ```0.6566```, i.e., It can model it ```65.66%``` over the training data, and the p-value is ```< 2.2e-16```. The below figure shows the value of the respective feature coefficients of the model.

![lmcoeff](/img/lmcoeff.png)

The accuracy of the Multiple Linear Regression Model using the features of NN Model II is ```91.7%```, Sensitivity is ```88.41%```, and Specificity is ```99.66%```, as shown in below figure.

![lmconfusionmatrix](/img/lmconfusionmatrix.png)


#### Comparison between Multiple Linear Regression Model and Neural Network Model

The Neural Network Model is more accurate and more sensitive, than the Multiple Linear Regression Model however Multiple Linear Regression Model is more specific than Neural Network Model.

Modeling | Accuracy | Sensitivity | Specificity
---      | ---      | ---         | ---
NN       | 96.09%   | 96.81%      | 94.32%
MLR      | 91.7%    | 88.41%      | 99.66%

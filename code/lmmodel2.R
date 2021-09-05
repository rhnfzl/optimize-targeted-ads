# Library -----------------------------------------------------------------
library(tidyverse)
library(tidymodels)
library(neuralnet)
set.seed(1011) # Setting random number seed so 

# Data Wrangling ----------------------------------------------------------

_dsetm2 <- read_csv("./data/_dset.csv")  %>% 
  select(-X1) %>% mutate(dear_john = as.character(dear_john))

summary(_dsetm2)

table(_dsetm2$cont_subs) %>% prop.table() # observing the proportion of final result, part of exploratory data analysis

split_dsetm2 <- initial_split(_dsetm2, prop = 0.799) # Splitting randomly the data to 80% training and 20% testing. Using 0.799 to workaround rounding and truncating error
training_dsetm2 <- training(split_dsetm2) # prepare the 80% full data for training data
test_dsetm2 <- testing(split_dsetm2) # prepare the 20% full data for test data

training_dsetm2 %>% summary()


# In the following script we are going to prepare the training and test dataset so it can be used in the simple neural network model
train_recipem2 <- training_dsetm2 %>% 
  recipe(cont_subs ~ series_hour + movie_hour + genre) %>% # Passing the model specification. Where the final as the outcome variable (RHS) and the other as the predictors (LHS) 
  step_center(series_hour, movie_hour) %>% # Centering and Normalizing the numerical variables
  step_dummy(genre, one_hot = TRUE) %>% # create one hot encoding for categorical variable
  prep(retain = TRUE) %>% # shows that the preparation is complete in this line
  juice() # Convert the recipe into a tibble or an enhanced data frame data type 

# We conduct the same steps to the test dataset  
test_recipem2 <- test_dsetm2 %>% 
  recipe(cont_subs ~ series_hour + movie_hour + genre) %>% # Passing the model specification. Where the final as the outcome variable (RHS) and the other as the predictors (LHS) 
  step_center(series_hour, movie_hour) %>% # Centering and Normalizing the numerical variables
  step_dummy(genre, one_hot = TRUE) %>% # create one hot encoding for categorical variable
  prep(retain = TRUE) %>% # shows that the preparation is complete in this line
  juice() # Convert the recipe into a tibble or an enhanced data frame data type 

attributes(train_recipem2)


# Model -------------------------------------------------------------------

my_lm_modelm2 <- lm(data = train_recipem2, # Same Table that has been used for NN Model 2
                   formula = cont_subs == "Yes" ~ series_hour + movie_hour +  
                                                 genre_Action + genre_Comedy +
                                                 genre_Documentary + genre_Drama + 
                                                 genre_Horror)

summary(my_lm_modelm2)

result_lmm2 <- predict(my_lm_modelm2, newdata = test_recipem2) #test data to the model



comparison_lm_tablem2 <- result_lmm2 %>% round() %>% as.data.frame()

#Rename
colnames(comparison_lm_tablem2) <- c("lmresultm2")


test_dsetm2 %>% select(cont_subs) %>% 
  mutate(testsetm2 = if_else(cont_subs == "Yes", 1, 0)) -> testsetm2


#Cleaning

comparison_lm_tablem2 <- bind_cols(comparison_lm_tablem2, testsetm2) %>% # Combining two datasets
  select(-cont_subs) %>% # Deselecting final column
  mutate(lmresultm2 = as.factor(if_else(lmresultm2 == 1, "Yes", "No")), # Changing the data type into factor so it can be used in the accuracy calculation
         testset = as.factor(if_else(testsetm2 == 1, "Yes", "No")))



# Calculate accuracy of the model
lm_accuracy <- accuracy(comparison_lm_tablem2,
                   truth = testset, 
                   estimate = lmresultm2)
# Accuracy
lm_accuracy



# Linear Regression Confusion matrix
conf_mat(comparison_lm_tablem2,
         truth = testset,
         estimate = lmresultm2) %>% autoplot(type = "heatmap") +
        scale_fill_gradient(low = "red", high = "green")


# Library -----------------------------------------------------------------
library(tidyverse)
library(tidymodels)
library(neuralnet)
set.seed(1009) # Setting random number seed so 

# Data Wrangling ----------------------------------------------------------

assignment_dset <- read_csv("./data/assignment2_dset.csv")  %>% 
  select(-X1)

str(_dset)

summary(_dset)

table(_dset$cont_subs) %>% prop.table() # observing the proportion of final result, part of exploratory data analysis

split_dset <- initial_split(_dset, prop = 0.799) # Splitting randomly the data to 80% training and 20% testing. Using 0.799 to workaround rounding and truncating error
training_dset <- training(split_dset) # prepare the 80% full data for training data
test_dset <- testing(split_dset) # prepare the 20% full data for test data

training_dset %>% summary()


# In the following script we are going to prepare the training and test dataset so it can be used in the simple neural network model
train_recipe <- training_dset %>% 
  recipe(cont_subs ~ sex + series_hour +
           movie_hour + age + watch_medium + household + gift +
           income + cont_watch + genre) %>% # Passing the model specification. Where the final as the outcome variable (RHS) and the other as the predictors (LHS) 
  step_center(series_hour, movie_hour, age, income,
              cont_watch) %>% # Centering and Normalizing the numerical variables
  step_dummy(sex, watch_medium, 
             household, gift, genre, one_hot = TRUE) %>% # create one hot encoding for categorical variable
  prep(retain = TRUE) %>% # shows that the preparation is complete in this line
  juice() # Convert the recipe into a tibble or an enhanced data frame data type 

# We conduct the same steps to the test dataset  
test_recipe <- test_dset %>% 
  recipe(cont_subs ~ sex + series_hour +
           movie_hour + age + watch_medium + household + gift +
           income + cont_watch + genre) %>% # Passing the model specification. Where the final as the outcome variable (RHS) and the other as the predictors (LHS) 
  step_center(series_hour, movie_hour, age, income,
              cont_watch) %>% # Centering and Normalizing the numerical variables
  step_dummy(sex, watch_medium, 
             household, gift, genre, one_hot = TRUE) %>% # create one hot encoding for categorical variable
  prep(retain = TRUE) %>% # shows that the preparation is complete in this line
  juice() # Convert the recipe into a tibble or an enhanced data frame data type 

attributes(train_recipe)

# Model -------------------------------------------------------------------
#?neuralnet()
# Here we use simple neuralnet verb from the neuralnet package to create the simple neural network model
mymodel <- neuralnet(
  data = train_recipe, # passing the dataset as an argument
  formula = cont_subs == "Yes" ~ series_hour + movie_hour + age + income + cont_watch + 
    sex_Female + sex_Male + watch_medium_Desktop + 
    watch_medium_Mobile + watch_medium_Smart.TV + household_Couple + household_Family + household_Shared.Subs + 
    household_Single + gift_No + gift_Yes + genre_Action + genre_Comedy +
    genre_Documentary + genre_Drama + genre_Horror,
  # Here we want to see the probability of pass result. The failed result can be specified as 1 - p(pass), therefore we don't need to explicitly specify it
  hidden = 6 # specifying the length of hidden layers inside the neural network (at the moment an aritrary numbers we are not going to optimize the number)
)


plot(mymodel) # Drawing your neural network model

resultnn <- compute(mymodel, test_recipe) #passing the test data to the model. This step test whether the model can predict the outcome of the test dataset given the test dataset inputs (assignment hours, lectures attended, and streaming used)

resultnn$net.result %>% round() %>% as.data.frame() %>%
  rename(nnresult = V1) -> comparison_table  # Making the dataset tidy as a dataframe or tibble

test_dset %>% select(cont_subs) %>% 
  mutate(testset = if_else(cont_subs == "Yes", 1, 0)) -> testset

resultnn <- compute(mymodel, test_recipe) #passing the test data to the model. This step test whether the model can predict the outcome of the test dataset given the test dataset inputs (assignment hours, lectures attended, and streaming used)

#comparison_table <- bind_cols(comparison_table, testset)
comparison_table <- bind_cols(comparison_table, testset) %>% # Combining two datasets
  select(-cont_subs) %>% # Deselecting final column
  mutate(nnresult = as.factor(if_else(nnresult == 1, "Yes", "No")), # Changing the data type into factor so it can be used in the accuracy calculation
         testset = as.factor(if_else(testset == 1, "Yes", "No")))

# The following script calculate how accurate your model is to predict the test data
accuracy(comparison_table, # passing the comparison table
         truth = testset, 
         estimate = nnresult)
# This number shows how many prediction made correctly by the model

# This matrix is a helping tool to visualize and calculate the sensistivity and specificity of your model
conf_mat(comparison_table,
         truth = testset,
         estimate = nnresult) %>% autoplot(type = "heatmap")   +
  scale_fill_gradient(low = "red", high = "green")

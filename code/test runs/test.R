# In the following script we are going to prepare the training and test dataset so it can be used in the simple neural network model
train_recipem1 <- _dsetm1 %>% 
  recipe(cont_subs ~ series_hour +
           movie_hour + genre) %>% # Passing the model specification. Where the final as the outcome variable (RHS) and the other as the predictors (LHS) 
  step_center(series_hour, movie_hour) %>% # Centering and Normalizing the numerical variables
  step_dummy(genre, one_hot = TRUE) %>% # create one hot encoding for categorical variable
  prep(retain = TRUE) %>% # shows that the preparation is complete in this line
  juice() # Convert the recipe into a tibble or an enhanced data frame data type 

# We conduct the same steps to the test dataset  
test_recipem1 <- test_dsetm1 %>% 
  recipe(cont_subs ~ series_hour +
           movie_hour + genre) %>% # Passing the model specification. Where the final as the outcome variable (RHS) and the other as the predictors (LHS) 
  step_center(series_hour, movie_hour) %>% # Centering and Normalizing the numerical variables
  step_dummy(genre, one_hot = TRUE) %>% # create one hot encoding for categorical variable
  prep(retain = TRUE) %>% # shows that the preparation is complete in this line
  juice() # Convert the recipe into a tibble or an enhanced data frame data type 

attributes(train_recipem1)


# Model -------------------------------------------------------------------
#?neuralnet()
# Here we use simple neuralnet verb from the neuralnet package to create the simple neural network model
mymodelm1 <- neuralnet(
  data = train_recipem1, # passing the dataset as an argument
  formula = cont_subs == "Yes" ~ series_hour + movie_hour + 
                                  genre_Action + genre_Comedy +
                                  genre_Documentary + genre_Drama + genre_Horror,
  # Here we want to see the probability of pass result. The failed result can be specified as 1 - p(pass), therefore we don't need to explicitly specify it
  hidden = 2 # specifying the length of hidden layers inside the neural network (at the moment an aritrary numbers we are not going to optimize the number)
)


plot(mymodelm1) # Drawing your neural network model

resultnnm1 <- compute(mymodelm1, test_recipem1) #passing the test data to the model. This step test whether the model can predict the outcome of the test dataset given the test dataset inputs (assignment hours, lectures attended, and streaming used)

resultnnm1$net.result %>% round() %>% as.data.frame() %>%
  rename(nnresult = V1) -> comparison_tablem1  # Making the dataset tidy as a dataframe or tibble

test_dsetm1 %>% select(cont_subs) %>% 
  mutate(testsetm1 = if_else(cont_subs == "Yes", 1, 0)) -> testsetm1

resultnnm1 <- compute(mymodelm1, test_recipem1) #passing the test data to the model. This step test whether the model can predict the outcome of the test dataset given the test dataset inputs (assignment hours, lectures attended, and streaming used)

#comparison_tablem1 <- bind_cols(comparison_tablem1, testsetm1)
comparison_tablem1 <- bind_cols(comparison_tablem1, testsetm1) %>% # Combining two datasets
  select(-cont_subs) %>% # Deselecting final column
  mutate(nnresult = as.factor(if_else(nnresult == 1, "Yes", "No")), # Changing the data type into factor so it can be used in the accuracy calculation
         testsetm1 = as.factor(if_else(testsetm1 == 1, "Yes", "No")))

# The following script calculate how accurate your model is to predict the test data
accuracy(comparison_tablem1, # passing the comparison table
         truth = testsetm1, 
         estimate = nnresult)
# This number shows how many prediction made correctly by the model

# This matrix is a helping tool to visualize and calculate the sensistivity and specificity of your model
conf_mat(comparison_tablem1,
         truth = testsetm1,
         estimate = nnresult) %>% autoplot(type = "heatmap") +
  scale_fill_gradient(low = "red", high = "green")

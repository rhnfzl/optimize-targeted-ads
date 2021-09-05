train_recipe <- training_dset %>% 
  recipe(cont_subs ~ sex + counties + series_hour +
           movie_hour + age + watch_medium + household + gift +
           income + cont_watch + dear_john + genre + facebook_lean + diehard) %>% # Passing the model specification. Where the final as the outcome variable (RHS) and the other as the predictors (LHS) 
  step_center(series_hour, movie_hour, age, income,
              cont_watch, dear_john) %>% # Centering and Normalizing the numerical variables
  step_dummy(sex, counties, watch_medium, 
             household, gift, genre, facebook_lean, diehard, one_hot = TRUE) %>% # create one hot encoding for categorical variable
  prep(retain = TRUE) %>% # shows that the preparation is complete in this line
  juice() # Convert the recipe into a tibble or an enhanced data frame data type 
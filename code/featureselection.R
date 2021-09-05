# Library -----------------------------------------------------------------
library(tidyverse)
library(tidymodels)
library(neuralnet)
library(e1071)
library(fpp2)
library(corrplot)
library(mgcv)
library(caret)
set.seed(1011) # Setting random number seed so 

# Data Wrangling ----------------------------------------------------------

assignment_dset <- read_csv("./data/assignment2_dset.csv")  %>% 
  select(-X1) %>% mutate(dear_john = as.character(dear_john))

summary(_dset)

table(_dset$cont_subs) %>% prop.table() # observing the proportion of final result, part of exploratory data analysis

split_dset <- initial_split(assignment_dset, prop = 0.999) # Splitting randomly the data to 80% training and 20% testing. Using 0.799 to workaround rounding and truncating error
training_dset <- training(split_dset) # prepare the 80% full data for training data
test_dset <- testing(split_dset) # prepare the 20% full data for test data

training_dset %>% summary()


# In the following script we are going to prepare the training and test dataset so it can be used in the simple neural network model
train_recipe <- training_dset %>% 
  recipe(cont_subs ~ sex + series_hour +
           movie_hour + age + watch_medium + household + gift +
           income + cont_watch + genre + facebook_lean) %>% # Passing the model specification. Where the final as the outcome variable (RHS) and the other as the predictors (LHS) 
  step_center(series_hour, movie_hour, age, income,
              cont_watch) %>% # Centering and Normalizing the numerical variables
  step_dummy(sex, watch_medium, 
             household, gift, genre, facebook_lean, one_hot = TRUE) %>% # create one hot encoding for categorical variable
  prep(retain = TRUE) %>% # shows that the preparation is complete in this line
  juice() # Convert the recipe into a tibble or an enhanced data frame data type 
#---------------------------------------------
summary(train_recipe)                     #---
attributes(train_recipe)                  #---
my_datax <- train_recipe[, c(1:5,7:25)]   #---Selecting only Numerical values
attributes(my_datax)  
M <- cor(my_datax)                        #---Claculating Correlation
head(round(M,2))                          #---Rounding it to two
#---------------------------------------------

cor.mtest <- function(mat, ...) {
  mat <- as.matrix(mat)
  n <- ncol(mat)
  p.mat<- matrix(NA, n, n)
  diag(p.mat) <- 0
  for (i in 1:(n - 1)) {
    for (j in (i + 1):n) {
      tmp <- cor.test(mat[, i], mat[, j], ...)
      p.mat[i, j] <- p.mat[j, i] <- tmp$p.value
    }
  }
  colnames(p.mat) <- rownames(p.mat) <- colnames(mat)
  p.mat
}

p.mat <- cor.mtest(my_datax)
attributes(p.mat)
head(p.mat[, 1:24])

col <- colorRampPalette(c("#BB4444", "#EE9988", "#FFFFFF", "#77AADD", "#4477AA"))
corrplot(M, method = "color", col = col(200),
         type = "upper", order = "hclust", number.cex = .7,
         addCoef.col = "black", # Add coefficient of correlation
         tl.col = "black", tl.srt = 90, # Text label color and rotation
         # Combine with significance
         p.mat = p.mat, sig.level = 0.01, insig = "blank", 
         # hide correlation coefficient on the principal diagonal
         diag = FALSE)

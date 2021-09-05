require(ggplot2)

summary(my_lm_modelm2)

summary(my_lm_modelm2)$coefficient

coef(my_lm_modelm2)[1]
coef(my_lm_modelm2)[3]
coef(my_lm_modelm2)[2]

install.packages("devtools")
devtools::install_github("cardiomoon/moonBook")
devtools::install_github("cardiomoon/moonBook2")
require(moonBook)
require(moonBook2)
require(ggplot2)
ggAncova(my_lm_modelm2,interactive=TRUE)
equation=function(x){coef(my_lm_modelm2)[2]*seriesH+
                    coef(my_lm_modelm2)[3]*moviesH+
                    coef(my_lm_modelm2)[4]*genereA+ 
                    coef(my_lm_modelm2)[5]*genereC+ 
                    coef(my_lm_modelm2)[6]*genereDo+ 
                    coef(my_lm_modelm2)[7]*genereDr+ 
                    coef(my_lm_modelm2)[1]}
library(ggiraphExtra)
ggPredict(my_lm_modelm2,se=TRUE,interactive=TRUE)

ggplot(training_dsetm2,aes(y=cont_subs,x=series_hour + movie_hour))+geom_point()

+
  stat_function(fun=equation,geom="line",color=scales::hue_pal()(2)[1])


ggplot(data = training_dsetm2, aes(x = series_hour + movie_hour, y = cont_subs, color=genre)) + #passing the mod table to create the plot
  geom_smooth(method = "lm") + # creating linear regression line in the plot layer  
  geom_point() # adding the points in the graph
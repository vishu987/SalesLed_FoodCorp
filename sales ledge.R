
# required libraries

library(tidyverse)
library(tidymodels)
library(car)
library(parsnip)
library(dplyr)
library(pROC)
library(ROCit)

options(scipen=999)

# reading the datas
# install.packages("openxlsx")
library("openxlsx")

slfi_train<- read.xlsx(r"{D:\Data\SQL\practice\Dummy Sales Ledger for Insight.xlsx}",detectDates=T, sep = ",")
# slfi_train
head(slfi_train)
names(slfi_train)
dim(slfi_train)
glimpse(slfi_train)
table(slfi_train$BILL_NO)
table(slfi_train$`BILL,DATE`)

## transfomraton fit
dp_pipe = recipe(TOTAL_VALUE ~ ., data = slfi_train) %>%
  update_role(BILL_NO,Sku_id,IS_FREE,`SALE,RETURN,QTY`,Order_Date,`BILL,DATE`, new_role = "drop_vars") %>%
  update_role(
    ZONE,
    Distributor_Name,
    `RETAILER,name`,
    Retailer_Category,
    Variant_Name,
  
    new_role = "to_dummies"
  ) %>%
  step_rm(has_role("drop_vars")) %>%
  step_unknown(has_role("to_dummies"), new_level = "__missing__") %>%
  step_other(has_role("to_dummies"),
             threshold = 0.005,
             other = "__other__") %>%
  step_dummy(has_role("to_dummies")) %>%
  step_impute_median(all_numeric(),-all_outcomes())

dp_pipe=prep(dp_pipe)

## final transformation -> from fit 
train=bake(dp_pipe,new_data=NULL)
test=bake(dp_pipe,new_data=slfi_train)

head(train)

head(test)


set.seed(2)
dim(train)
s=sample(1:nrow(train),0.8*nrow(train))
t1=train[s,] ## create as model
t2=train[-s,] ## validating this dataset

visdat::vis_dat(train)

# computing vif
head(t1$TOTAL_VALUE)



fit = lm(TOTAL_VALUE ~ . -CGST -CGST_AMT                         -ZONE_X__other__ -Distributor_Name_ANN.ENTERPRISE  -Distributor_Name_SSS.MARKETING   -Distributor_Name_XYZ.ENTERPRISE  -Distributor_Name_X__other__    -Retailer_Category_BIG.BASKET -TAXABLE_AMT -SGST -Category_Name -`RETAILER,name_X__other__` -Retailer_Category_GT -Variant_Name_Chicken.Nuggets -GROSS_AMT -ZONE_West.Zone -ZONE_South.Zone -Distributor_Name_DAS.DISTRIBUTORS , data = t1)

alias(fit)

sort(vif(fit),decreasing = T)

# we'll take vif cutoff as 5


fit=lm(TOTAL_VALUE ~ . -CGST -CGST_AMT                         -ZONE_X__other__ -Distributor_Name_ANN.ENTERPRISE  -Distributor_Name_SSS.MARKETING   -Distributor_Name_XYZ.ENTERPRISE  -Distributor_Name_X__other__    -Retailer_Category_BIG.BASKET -TAXABLE_AMT -SGST -Category_Name -`RETAILER,name_X__other__` -Retailer_Category_GT -Variant_Name_Chicken.Nuggets -GROSS_AMT -ZONE_West.Zone -ZONE_South.Zone -Distributor_Name_DAS.DISTRIBUTORS -`QTY,purchased,in,Pieces` -SGST_AMT -RATE -MRP -`RETAILER,name_online` -`RETAILER,name_Spencer.Southcity` , data = t1)

sort(vif(fit),decreasing = T)


# p-value take the cutoff 0.1

summary(fit)

fit=stats::step(fit)

## AIC score 

summary(fit)


formula(fit)




fit=lm(TOTAL_VALUE ~ IGST + ZONE_North.Zone + Distributor_Name_S.A..ENTERPRISES + 
         `RETAILER,name_ARAMBAGH.FOOD.MART...KASBA.` + `RETAILER,name_ARAMBAGH.FOOD.MART..CHANDAN.NAGAR.1.` + 
         `RETAILER,name_ARAMBAGH.FOOD.MART.BAGUIATI` + `RETAILER,name_Arambagh.Food.mart.DC.Bolpur` + 
         `RETAILER,name_Arambagh.Food.mart.DC.Sriniketan` + `RETAILER,name_ARAMBAGH.FOOD.MART.SHAPOORJI` + 
         `RETAILER,name_ARAMBAGH.FOOD.MART.SUNRISE` + `RETAILER,name_CASH.SALES` + 
         `RETAILER,name_Easy.mart` + `RETAILER,name_GNRC.MEDISHOP.Hatigaon` + 
         `RETAILER,name_GR8.CONVENIENCE.STORE` + `RETAILER,name_More.DLF.Hyper` + 
         `RETAILER,name_NILIMA.CONFECTIONERS` + `RETAILER,name_Prabha` + 
         `RETAILER,name_SPENCER.S.AVISHAR` + `RETAILER,name_SPENCER.S.SANTINEER` + 
         `RETAILER,name_SPENCER.S.UPOHER` + `RETAILER,name_SUNNY.SHOPING.CENTRE` + 
         `RETAILER,name_Upobhog` + Retailer_Category_Big.Bazar + Retailer_Category_EASY.DAY + 
         Retailer_Category_MORE.RETAIL + Retailer_Category_SPENCER.S + 
         Retailer_Category_X__other__ + Variant_Name_Breakfast.Salami + 
         Variant_Name_Breakfast.Sausages + Variant_Name_Cheese...Onion.Sausages + 
         Variant_Name_Cheese.Corn.Nuggets + Variant_Name_Chicken...Cheese.Nuggets + 
         Variant_Name_Chicken.Finger + Variant_Name_Chicken.Gravy + 
         Variant_Name_Chicken.Hariyali.Kabab + Variant_Name_Chicken.Masala.Nuggets + 
         Variant_Name_Chicken.Party.Pack + Variant_Name_Chicken.Popcorn + 
         Variant_Name_Chicken.Seekh.Kabab + Variant_Name_Chicken.Strips + 
         Variant_Name_Chicken.Tikkas + Variant_Name_Chilli.Salami + 
         Variant_Name_Chilli.Sausages + Variant_Name_French.Fries + 
         Variant_Name_Green.Peas + Variant_Name_Italian.Sausages + 
         Variant_Name_Paneer.Nuggets + Variant_Name_Parathas + Variant_Name_Pepper...Herb.Salami + 
         Variant_Name_Pepper...Herb.Sausages + Variant_Name_Potato.Cheese.Bites + 
         Variant_Name_Sweet.Corn + Variant_Name_Veg.Cheese.Finger + 
         Variant_Name_Veg.Cutlet + Variant_Name_Veg.Masala.Nugget + 
         Variant_Name_Veg.Sticks + Variant_Name_X__other__,
       data=t1)

summary(fit)

###

t2.pred=predict(fit,newdata=t2)

errors=t2$TOTAL_VALUE-t2.pred
errors_train = t1$TOTAL_VALUE - predict(fit, t1)
## residual
## test
rmse=errors**2 %>% mean() %>% sqrt()
mae=mean(abs(errors))
## train
rmse_train = errors_train**2 %>% mean() %>% sqrt()
mae_train = mean(abs(errors_train))


### model for predcition on the entire data

fit.final=lm(TOTAL_VALUE ~ IGST + ZONE_North.Zone + Distributor_Name_S.A..ENTERPRISES + 
               `RETAILER,name_ARAMBAGH.FOOD.MART...KASBA.` + `RETAILER,name_ARAMBAGH.FOOD.MART..CHANDAN.NAGAR.1.` + 
               `RETAILER,name_ARAMBAGH.FOOD.MART.BAGUIATI` + `RETAILER,name_Arambagh.Food.mart.DC.Bolpur` + 
               `RETAILER,name_Arambagh.Food.mart.DC.Sriniketan` + `RETAILER,name_ARAMBAGH.FOOD.MART.SHAPOORJI` + 
               `RETAILER,name_ARAMBAGH.FOOD.MART.SUNRISE` + `RETAILER,name_CASH.SALES` + 
               `RETAILER,name_Easy.mart` + `RETAILER,name_GNRC.MEDISHOP.Hatigaon` + 
               `RETAILER,name_GR8.CONVENIENCE.STORE` + `RETAILER,name_More.DLF.Hyper` + 
               `RETAILER,name_NILIMA.CONFECTIONERS` + `RETAILER,name_Prabha` + 
               `RETAILER,name_SPENCER.S.AVISHAR` + `RETAILER,name_SPENCER.S.SANTINEER` + 
               `RETAILER,name_SPENCER.S.UPOHER` + `RETAILER,name_SUNNY.SHOPING.CENTRE` + 
               `RETAILER,name_Upobhog` + Retailer_Category_Big.Bazar + Retailer_Category_EASY.DAY + 
               Retailer_Category_MORE.RETAIL + Retailer_Category_SPENCER.S + 
               Retailer_Category_X__other__ + Variant_Name_Breakfast.Salami + 
               Variant_Name_Breakfast.Sausages + Variant_Name_Cheese...Onion.Sausages + 
               Variant_Name_Cheese.Corn.Nuggets + Variant_Name_Chicken...Cheese.Nuggets + 
               Variant_Name_Chicken.Finger + Variant_Name_Chicken.Gravy + 
               Variant_Name_Chicken.Hariyali.Kabab + Variant_Name_Chicken.Masala.Nuggets + 
               Variant_Name_Chicken.Party.Pack + Variant_Name_Chicken.Popcorn + 
               Variant_Name_Chicken.Seekh.Kabab + Variant_Name_Chicken.Strips + 
               Variant_Name_Chicken.Tikkas + Variant_Name_Chilli.Salami + 
               Variant_Name_Chilli.Sausages + Variant_Name_French.Fries + 
               Variant_Name_Green.Peas + Variant_Name_Italian.Sausages + 
               Variant_Name_Paneer.Nuggets + Variant_Name_Parathas + Variant_Name_Pepper...Herb.Salami + 
               Variant_Name_Pepper...Herb.Sausages + Variant_Name_Potato.Cheese.Bites + 
               Variant_Name_Sweet.Corn + Variant_Name_Veg.Cheese.Finger + 
               Variant_Name_Veg.Cutlet + Variant_Name_Veg.Masala.Nugget + 
               Variant_Name_Veg.Sticks + Variant_Name_X__other__, data = t1)

sort(vif(fit.final),decreasing = T)

fit.final=stats::step(fit.final)

summary(fit.final)


formula(fit.final)

fit.final=lm(TOTAL_VALUE ~ IGST + ZONE_North.Zone + Distributor_Name_S.A..ENTERPRISES + 
               `RETAILER,name_ARAMBAGH.FOOD.MART...KASBA.` + `RETAILER,name_ARAMBAGH.FOOD.MART..CHANDAN.NAGAR.1.` + 
               `RETAILER,name_ARAMBAGH.FOOD.MART.BAGUIATI` + `RETAILER,name_Arambagh.Food.mart.DC.Bolpur` + 
               `RETAILER,name_Arambagh.Food.mart.DC.Sriniketan` + `RETAILER,name_ARAMBAGH.FOOD.MART.SHAPOORJI` + 
               `RETAILER,name_ARAMBAGH.FOOD.MART.SUNRISE` + `RETAILER,name_CASH.SALES` + 
               `RETAILER,name_Easy.mart` + `RETAILER,name_GNRC.MEDISHOP.Hatigaon` + 
               `RETAILER,name_GR8.CONVENIENCE.STORE` + `RETAILER,name_More.DLF.Hyper` + 
               `RETAILER,name_NILIMA.CONFECTIONERS` + `RETAILER,name_Prabha` + 
               `RETAILER,name_SPENCER.S.AVISHAR` + `RETAILER,name_SPENCER.S.SANTINEER` + 
               `RETAILER,name_SPENCER.S.UPOHER` + `RETAILER,name_SUNNY.SHOPING.CENTRE` + 
               `RETAILER,name_Upobhog` + Retailer_Category_Big.Bazar + Retailer_Category_EASY.DAY + 
               Retailer_Category_MORE.RETAIL + Retailer_Category_SPENCER.S + 
               Retailer_Category_X__other__ + Variant_Name_Breakfast.Salami + 
               Variant_Name_Breakfast.Sausages + Variant_Name_Cheese...Onion.Sausages + 
               Variant_Name_Cheese.Corn.Nuggets + Variant_Name_Chicken...Cheese.Nuggets + 
               Variant_Name_Chicken.Finger + Variant_Name_Chicken.Gravy + 
               Variant_Name_Chicken.Hariyali.Kabab + Variant_Name_Chicken.Masala.Nuggets + 
               Variant_Name_Chicken.Party.Pack + Variant_Name_Chicken.Popcorn + 
               Variant_Name_Chicken.Seekh.Kabab + Variant_Name_Chicken.Strips + 
               Variant_Name_Chicken.Tikkas + Variant_Name_Chilli.Salami + 
               Variant_Name_Chilli.Sausages + Variant_Name_French.Fries + 
               Variant_Name_Green.Peas + Variant_Name_Italian.Sausages + 
               Variant_Name_Paneer.Nuggets + Variant_Name_Parathas + Variant_Name_Pepper...Herb.Salami + 
               Variant_Name_Pepper...Herb.Sausages + Variant_Name_Potato.Cheese.Bites + 
               Variant_Name_Sweet.Corn + Variant_Name_Veg.Cheese.Finger + 
               Variant_Name_Veg.Cutlet + Variant_Name_Veg.Masala.Nugget + 
               Variant_Name_Veg.Sticks + Variant_Name_X__other__ , data = t1)

summary(fit.final)

nm <- names(fit.final$coefficients)

nm <- nm[6:length(nm)]

pairs(train[,c('TOTAL_VALUE', nm) ])

## solving your projects, this file is to be required for submission

test.pred=predict(fit.final,newdata=test)


write.csv(test.pred,"Predicted_Value_SLFI.csv",row.names = F)

### 

plot(fit.final,1) # residual vs fitted values => non-linearity in the data exists or not

plot(fit.final,2) # errors are normal or not

plot(fit.final,3) # variance is constant or not

plot(fit.final,4) # outliers in the data if cook's distance >1



durbinWatsonTest(fit.final)

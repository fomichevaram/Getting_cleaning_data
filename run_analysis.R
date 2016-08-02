### Loading libraries ###

library(dplyr)
library(tidyr)
library(data.table)

### Check if directory exists. Otherwise - create dir and download data ###
if (dir.exists('./Project') == F){dir.create('./Project')
download.file('https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip', extra = "curl",destfile = './Project/dataset.zip')
unzip('./Project/dataset.zip', exdir = './Project/unzipdf')}

### Setting the working directory ###
setwd('./Project/unzipdf/UCI HAR Dataset/')

### Loading all raw datasets ###
testdf <- fread('./test/X_test.txt')
testy <- fread('./test/y_test.txt')
testsubj <- fread('./test/subject_test.txt')
traindf <- fread('./train/X_train.txt')
trainy <- fread('./train/y_train.txt')
trainsubj <- fread('./train/subject_train.txt')

### Creating vector of names for features ###
labelstest <- fread('features.txt')
lst <- grepl('([Mm]ean|[Ss]td)',labelstest$V2)

### Reading activity types ###
activities <- fread('activity_labels.txt')

### Binding all the raw test and train datasets ###
### Assigning colnames for all columns ###
### Creating factors from existing vars ###
### Cleaning workspace ###
xdata <- bind_rows(testdf, traindf); colnames(xdata) <- labelstest[[2]]; xdata <- xdata[,lst]
ydata <- bind_rows(testy, trainy); colnames(ydata) <- 'Activities'; ydata[[1]] <- factor(ydata[[1]], levels = activities$V1, labels = activities$V2)
subjdata <- bind_rows(testsubj, trainsubj); colnames(subjdata) <- 'Subject'
rm(list = ls()[!grepl('data',ls())])

### Binding tidy dataframes ###
### Melting and casting dataframes for tisy datasets with average for each column with means and SDs for each activity type for every subject ###
mainframe <- cbind(subjdata, ydata, xdata)
rm(list = c('xdata','ydata','subjdata'))
mainframemelt <- melt(data = mainframe, id = c("Activities", "Subject"))
mainframecast <- dcast(mainframemelt, Activities + Subject ~ variable, mean)
mainframecast <- arrange(mainframecast, Subject, Activities)

### Saving dataframe ###
write.table(x = mainframecast, 'tidydataset.txt', row.names = F)

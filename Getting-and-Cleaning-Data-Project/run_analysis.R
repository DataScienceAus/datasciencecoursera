## This script performs the following steps:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names.
## 5. Outputs a new data set with the average of each variable for each activity and each subject.


require("data.table")
require("reshape2")

#Load all data
xTest <- read.table("data/test/X_test.txt")
yTest <- read.table("data/test/Y_test.txt")

xTrain <- read.table("data/train/x_train.txt")
yTrain <- read.table("data/train/y_train.txt")

subjectTest <- read.table("data/test/subject_test.txt")
subjectTrain <- read.table("data/train/subject_train.txt")

activityLabels <- read.table("data/activity_labels.txt")[,2]
features <- read.table("data/features.txt")[,2]

# Extract only the measurements on the mean and standard deviation for each measurement.
requiredFeatures <- grepl("mean|std", features)


# Assign new column names to test data
names(xTest) <- features

# Extract only the measurements on the mean and standard deviation for each measurement.
xTest <- xTest[,requiredFeatures]

# Assign activity labels for test data
yTest[,2] = activityLabels[yTest[,1]]
names(yTest) = c("ActivityId", "Activity")
names(subjectTest) = "Subject"

# Bind test data
testData <- cbind(as.data.table(subjectTest), yTest, xTest)

# Assign new column names to train data
names(xTrain) = features

# Extract only the measurements on the mean and standard deviation for each measurement.
xTrain = xTrain[,requiredFeatures]

# Assign activity labels for train data
yTrain[,2] = activityLabels[yTrain[,1]]
names(yTrain) = c("ActivityId", "Activity")
names(subjectTrain) = "Subject"

# Bind train data
trainData <- cbind(as.data.table(subjectTrain), yTrain, xTrain)

# Merge test and train datasets
newData = rbind(testData, trainData)

# Define our column names
columnLabels   = c("Subject", "ActivityId", "Activity")

# Create row labels out of the columns in new data that are not our id's
rowLabels = setdiff(colnames(newData), columnLabels)
mData = melt(newData, id = columnLabels, measure.vars = rowLabels)

# Aggregate the dataset using the mean function
outputData = dcast(mData, Subject + Activity ~ variable, mean)


# Output the final dataset
write.table(outputData, file = "tidy.txt")
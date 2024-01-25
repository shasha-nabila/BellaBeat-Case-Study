# Install the packages
install.packages("tidyverse")
install.packages("janitor")
install.packages("skimr")
install.packages("lubridate")
install.packages("ggplot2")
install.packages("dplyr")

# Load the packages
library(tidyverse)
library(janitor)
library(skimr)
library(lubridate)
library(ggplot2)
library(dplyr)

# Set working directory
setwd("C:/Users/DELL/Downloads/bellabeat/Fitabase Data 4.12.16-5.12.16")
head(list.files())

# Importing datasets
daily_activity <- read.csv("dailyActivity_merged.csv")
daily_calories <- read.csv("dailyCalories_merged.csv")
daily_steps <- read.csv("dailySteps_merged.csv")
daily_sleep <- read.csv("sleepDay_merged.csv")

# Inspect format errors
str(daily_activity)
str(daily_calories)
str(daily_steps)
str(daily_sleep)

# Convert to date & determine weekdays
daily_activity <- daily_activity %>% 
  mutate(ActivityDate = as.Date(ActivityDate,"%m/%d/%Y"),
  Weekday = weekdays(ActivityDate))
daily_calories <- daily_calories %>%
  mutate(ActivityDay = as.Date(ActivityDay, "%m/%d/%Y"),
  Weekday = weekdays(ActivityDay))
daily_steps <- daily_steps %>% 
  mutate(ActivityDay = as.Date(ActivityDay, "%m/%d/%Y"),
  Weekday = weekdays(ActivityDay))
daily_sleep <- daily_sleep %>% 
  mutate(Weekday = weekdays(as.Date(SleepDay, "%m/%d/%Y")))

# Separating date from time
cleaned_daily_sleep <- daily_sleep %>% 
  separate(SleepDay, c("Date", "Time"), " ")

# Converting Date column to date format
cleaned_daily_sleep$Date <- as.Date(cleaned_daily_sleep$Date, "%m/%d/%Y")

# Check for duplicates
daily_activity %>% duplicated() %>% sum()
daily_calories %>% duplicated() %>% sum()
daily_steps %>% duplicated() %>% sum()
cleaned_daily_sleep %>% duplicated() %>% sum()

# Removing duplicates & check again
cleaned_daily_sleep <- cleaned_daily_sleep %>% distinct() %>% drop_na()
cleaned_daily_sleep %>% duplicated() %>% sum()

# Checking number of participants
n_distinct(daily_activity$Id)
n_distinct(daily_calories$Id)
n_distinct(daily_steps$Id)
n_distinct(cleaned_daily_sleep$Id)

# Renaming ActivityDate column to Date
daily_activity <- daily_activity %>% rename(Date = ActivityDate)

# Combining daily_activity with cleaned_daily_sleep on both Id & Date
combined_activity_and_sleep <- merge(daily_activity, cleaned_daily_sleep,
                                     by = c("Id", "Date"))

# Statistical summaries
daily_activity %>% 
  select(VeryActiveMinutes, FairlyActiveMinutes, LightlyActiveMinutes,
         SedentaryMinutes) %>%
  summary()
daily_steps %>% select(StepTotal) %>% summary()
cleaned_daily_sleep %>% select(TotalMinutesAsleep) %>% summary()

# Compute average steps per day
average_steps_per_day <- daily_steps %>%
  group_by(Weekday) %>%
  summarise(AverageSteps = mean(StepTotal))

# Placing weekdays in order
daily_steps$Weekday <- factor(
  daily_steps$Weekday, levels = c("Sunday", "Monday", "Tuesday", "Wednesday",
                                  "Thursday", "Friday", "Saturday"))

# Visualise average steps per day
ggplot(average_steps_per_day, aes(x = Weekday, y = AverageSteps)) +
  geom_col(fill = 'skyblue') +
  labs(title = "Average Steps Taken per Day", x = "Day of the Week",
       y = "Average Steps")

# Visualise total steps against calories burned
ggplot(daily_activity, aes(x = TotalSteps, y = Calories)) +
  geom_point(color = 'orange') + geom_smooth() +
  labs(title = "Total Steps vs Calories Burned", x = "Total Steps", y =
      "Calories Burned")

# Compute the correlation between total steps and calories burned
cor(daily_activity$TotalSteps, daily_activity$Calories, method = "pearson")

# Visualise total minutes asleep against sedentary minutes
ggplot(combined_activity_and_sleep,
       aes(x = TotalMinutesAsleep, y = SedentaryMinutes)) + 
  geom_point(color = 'maroon') + geom_smooth() +
  labs(title = "Total Minutes Asleep vs Sedentary Minutes",
       x = "Total Minutes Asleep", y = "Sedentary Minutes")

# Compute the correlation between total minutes asleep and sedentary minutes
cor(combined_activity_and_sleep$TotalMinutesAsleep,
  combined_activity_and_sleep$SedentaryMinutes, method = "pearson")

# Visualise total minutes asleep against total minutes in bed
ggplot(cleaned_daily_sleep, aes(x = TotalMinutesAsleep, y = TotalTimeInBed)) +
  geom_point() + geom_smooth() +
  labs(title = 'Total Minutes Asleep vs Total Minutes in Bed',
       x = 'Total Minutes Asleep', y = 'Total Minutes in Bed')

# Compute the correlation between total minutes asleep and total minutes in bed
cor(combined_activity_and_sleep$TotalMinutesAsleep,
    combined_activity_and_sleep$TotalTimeInBed, method = "pearson")


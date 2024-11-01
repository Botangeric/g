#### Preamble ####
# Purpose: Cleans the raw plane data recorded by two observers..... [...UPDATE THIS...]
# Author: Rohan Alexander [...UPDATE THIS...]
# Date: 6 April 2023 [...UPDATE THIS...]
# Contact: rohan.alexander@utoronto.ca [...UPDATE THIS...]
# License: MIT
# Pre-requisites: [...UPDATE THIS...]
# Any other information needed? [...UPDATE THIS...]

#### Workspace setup ####
library(tidyverse)
library(arrow)
library(janitor)

#### Clean data ####
#### Prepare dataset ####
# Read in the data and clean variable names
data <- read_csv("data/01-raw_data/president_polls.csv") |>
  clean_names()

# Filter data to Trump estimates based on high-quality polls after she declared
clean_data <- data |>
  filter(
    candidate_name == "Donald Trump",
    numeric_grade >= 2 # high-quality polls only 
  ) |>
  mutate( # if missing state, make it national
    state = if_else(is.na(state), "National", state), 
    end_date = mdy(end_date)
  ) |>
  filter(end_date >= as.Date("2022-11-15")) |> # When Trump declared
  select(pct, pollster, state, end_date, pollscore, party,methodology,sample_size) %>% na.omit()

#### Plot data ####
base_plot <- ggplot(clean_data, aes(x = end_date, y = pct)) +
  theme_classic() +
  labs(y = "Trump percent", x = "Date")

# Plots poll estimates and overall smoothing
base_plot +
  geom_point() +
  geom_smooth()

# Color by pollster
# This gets messy - need to add a filter - see line 21
base_plot +
  geom_point(aes(color = pollster)) +
  geom_smooth() +
  theme(legend.position = "bottom")

# Facet by pollster
# Make the line 21 issue obvious
# Also - is there duplication???? Need to go back and check
base_plot +
  geom_point() +
  geom_smooth() +
  facet_wrap(vars(pollster))

# Color by pollscore
base_plot +
  geom_point(aes(color = factor(pollscore))) +
  geom_smooth() +
  theme(legend.position = "bottom")


#### Save data ####
write.csv(clean_data,"data/02-analysis_data/analysis_data.csv")
write_parquet(x = clean_data,
              sink = "data/02-analysis_data/analysis_data.parquet")





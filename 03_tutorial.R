# Tidyverse Tutorial: Grouping and Summarizing Data
# Using events_saved.rds dataset

# Load necessary libraries
library(tidyverse)
library(lubridate) # For date handling

# Load the events data
events_data <- readRDS("events_saved.rds")

# First, let's examine our data structure
str(events_data)
head(events_data)
colnames(events_data)
dim(events_data)

# ============================================================================
# DATA CLEANING AND PREPARATION
# ============================================================================

# Before analyzing data, we often need to clean and prepare it. Real-world 
# datasets frequently have missing values, inconsistent formatting, duplicates,
# and incorrect data types. The tidyverse provides excellent tools for these tasks.

# Let's first examine data quality issues in our dataset
summary(events_data)

# Check for missing values across all columns
events_data %>%
  summarise_all(~sum(is.na(.)))

# Check for duplicate rows
nrow(events_data)  # Total rows
events_data %>%
  distinct() %>%
  nrow()  # Unique rows after removing duplicates

# Example 1: Handling missing values
# Remove rows where critical columns are missing
cleaned_events <- events_data %>%
  filter(!is.na(cand_name), !is.na(state))

# Alternative approach: use drop_na() for multiple columns at once
cleaned_events <- events_data %>%
  drop_na(cand_name, state)

# Example 2: String cleaning and standardization
cleaned_events <- cleaned_events %>%
  mutate(
    # Clean candidate names - remove extra whitespace and standardize case
    cand_name = str_trim(cand_name),
    cand_name = str_to_title(cand_name),
    # Clean state names - handle common variations
    state = str_trim(state),
    state = str_to_upper(state)
  )

# Example 3: Handling data type conversions
# Check current data types
str(cleaned_events)

# Convert character columns to factors where appropriate
cleaned_events <- cleaned_events %>%
  mutate(
    cand_name = as.factor(cand_name),
    state = as.factor(state)
  )

# Example 4: Removing exact duplicates
cleaned_events <- cleaned_events %>%
  distinct()

# Example 5: Creating clean, analysis-ready dataset
# Apply all cleaning steps in one pipeline
analysis_ready_data <- events_data %>%
  # Remove missing critical data
  filter(!is.na(cand_name), !is.na(state)) %>%
  # Clean strings
  mutate(
    cand_name = str_trim(str_to_title(cand_name)),
    state = str_trim(str_to_upper(state))
  ) %>%
  # Convert to appropriate types
  mutate(
    cand_name = as.factor(cand_name),
    state = as.factor(state)
  ) %>%
  # Remove duplicates
  distinct()

# Compare original vs cleaned data
nrow(events_data)  # Original
nrow(analysis_ready_data)  # After cleaning

# Use the cleaned data for all subsequent analysis
events_data <- analysis_ready_data

# ============================================================================
# TUTORIAL: GROUPING AND SUMMARIZING WITH TIDYVERSE
# ============================================================================

# The power of tidyverse comes from its ability to group data and calculate
# summary statistics efficiently. We'll use the pipe operator (%>%) to chain
# operations together for readable, sequential data processing.

# ============================================================================
# BASIC GROUP_BY AND SUMMARISE
# ============================================================================

# Example 1: Count events by candidate
candidate_counts <- events_data %>%
  group_by(cand_name) %>%
  summarise(
    event_count = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(event_count))

candidate_counts

# Example 2: Events by state
state_summary <- events_data %>%
  group_by(state) %>%
  summarise(
    event_count = n(),
    unique_candidates = n_distinct(cand_name),
    .groups = "drop"
  ) %>%
  arrange(desc(event_count))

head(state_summary, 10)

# ============================================================================
# MULTIPLE GROUPING VARIABLES
# ============================================================================

# Example 3: Events by candidate AND state
candidate_state_summary <- events_data %>%
  group_by(cand_name, state) %>%
  summarise(
    event_count = n(),
    .groups = "drop"
  ) %>%
  arrange(cand_name, desc(event_count))

head(candidate_state_summary, 15)

# ============================================================================
# ADVANCED SUMMARISE FUNCTIONS
# ============================================================================

# Example 4: Multiple summary statistics

# First, let's check if we have date information
if ("date" %in% colnames(events_data) || "event_date" %in% colnames(events_data)) {
  # If we have dates, use them for time-based analysis
  date_col <- ifelse("date" %in% colnames(events_data), "date", "event_date")
  
  advanced_summary <- events_data %>%
    group_by(cand_name) %>%
    summarise(
      total_events = n(),
      states_visited = n_distinct(state),
      first_event = min(get(date_col), na.rm = TRUE),
      last_event = max(get(date_col), na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(desc(total_events))
} else {
  # If no dates, focus on geographic coverage
  advanced_summary <- events_data %>%
    group_by(cand_name) %>%
    summarise(
      total_events = n(),
      states_visited = n_distinct(state),
      cities_visited = n_distinct(city),
      .groups = "drop"
    ) %>%
    arrange(desc(total_events))
}

advanced_summary

# ============================================================================
# FILTERING WITH GROUPS
# ============================================================================

# Example 5: Find candidates with events in multiple states
multi_state_candidates <- events_data %>%
  group_by(cand_name) %>%
  summarise(
    states_count = n_distinct(state),
    total_events = n(),
    .groups = "drop"
  ) %>%
  filter(states_count >= 3) %>%
  arrange(desc(states_count))

multi_state_candidates

# ============================================================================
# CONDITIONAL SUMMARIZING
# ============================================================================

# Example 6: Conditional summaries using case_when or ifelse
campaign_intensity <- events_data %>%
  group_by(cand_name) %>%
  summarise(
    total_events = n(),
    states_visited = n_distinct(state),
    .groups = "drop"
  ) %>%
  mutate(
    campaign_intensity = case_when(
      total_events >= 50 ~ "High Activity",
      total_events >= 20 ~ "Moderate Activity",
      total_events >= 10 ~ "Low Activity",
      TRUE ~ "Minimal Activity"
    )
  ) %>%
  arrange(desc(total_events))

campaign_intensity

# Example 7: Summary by campaign intensity category
intensity_summary <- campaign_intensity %>%
  group_by(campaign_intensity) %>%
  summarise(
    candidates_count = n(),
    avg_events = round(mean(total_events), 1),
    avg_states = round(mean(states_visited), 1),
    .groups = "drop"
  )

intensity_summary

# ============================================================================
# TOP N ANALYSIS
# ============================================================================

# Example 8: Top states by event activity
top_states <- events_data %>%
  group_by(state) %>%
  summarise(
    total_events = n(),
    unique_candidates = n_distinct(cand_name),
    .groups = "drop"
  ) %>%
  slice_max(total_events, n = 10) %>%
  mutate(
    events_per_candidate = round(total_events / unique_candidates, 1)
  )

top_states

# ============================================================================
# COMBINING OPERATIONS
# ============================================================================

# Example 9: Complex analysis combining multiple operations
comprehensive_analysis <- events_data %>%
  # First, let's see what we're working with
  group_by(state, cand_name) %>%
  summarise(
    candidate_events = n(),
    .groups = "keep"
  ) %>%
  # Now summarize by state
  group_by(state) %>%
  summarise(
    total_events = sum(candidate_events),
    num_candidates = n(),
    max_events_by_candidate = max(candidate_events),
    min_events_by_candidate = min(candidate_events),
    avg_events_per_candidate = round(mean(candidate_events), 1),
    .groups = "drop"
  ) %>%
  filter(total_events >= 5) %>%  # Focus on states with meaningful activity
  arrange(desc(total_events))

head(comprehensive_analysis, 15)

# ============================================================================
# PIVOT_WIDER: TRANSFORMING DATA FROM LONG TO WIDE FORMAT
# ============================================================================

# pivot_wider() is essential for creating comparison tables and matrices
# It transforms data from "long" format (many rows) to "wide" format (many columns)

# Example 10: Create a candidate-by-state events matrix
candidate_state_matrix <- events_data %>%
  group_by(cand_name, state) %>%
  summarise(
    event_count = n(),
    .groups = "drop"
  ) %>%
  pivot_wider(
    names_from = state,
    values_from = event_count,
    values_fill = 0
  )

candidate_state_matrix

# Example 11: Focus on top candidates and top states for cleaner comparison
# First identify top candidates and states
top_candidates <- events_data %>%
  count(cand_name, sort = TRUE) %>%
  head(8) %>%
  pull(cand_name)

top_states <- events_data %>%
  count(state, sort = TRUE) %>%
  head(10) %>%
  pull(state)

# Create focused comparison matrix
focused_matrix <- events_data %>%
  filter(cand_name %in% top_candidates, state %in% top_states) %>%
  group_by(cand_name, state) %>%
  summarise(
    events = n(),
    .groups = "drop"
  ) %>%
  pivot_wider(
    names_from = state,
    values_from = events,
    values_fill = 0
  ) %>%
  arrange(desc(rowSums(select(., -cand_name))))

focused_matrix

# Example 12: Calculate percentages within candidates
# This shows what percentage of each candidate's events occurred in each state
candidate_state_percentages <- events_data %>%
  group_by(cand_name, state) %>%
  summarise(
    events = n(),
    .groups = "drop"
  ) %>%
  group_by(cand_name) %>%
  mutate(
    total_events = sum(events),
    percentage = round(events / total_events * 100, 1)
  ) %>%
  select(cand_name, state, percentage) %>%
  pivot_wider(
    names_from = state,
    values_from = percentage,
    values_fill = 0
  )

# Show only top candidates for readability
candidate_state_percentages %>%
  filter(cand_name %in% top_candidates) %>%
  select(cand_name, all_of(top_states))

# Example 13: Creating summary statistics in wide format
# Compare min, max, mean events per state for top candidates
candidate_summary_wide <- events_data %>%
  filter(cand_name %in% top_candidates) %>%
  group_by(cand_name, state) %>%
  summarise(
    events = n(),
    .groups = "drop"
  ) %>%
  group_by(cand_name) %>%
  summarise(
    min_events_per_state = min(events),
    max_events_per_state = max(events),
    avg_events_per_state = round(mean(events), 1),
    states_visited = n(),
    .groups = "drop"
  ) %>%
  pivot_longer(
    cols = c(min_events_per_state, max_events_per_state, avg_events_per_state),
    names_to = "metric",
    values_to = "value"
  ) %>%
  pivot_wider(
    names_from = cand_name,
    values_from = value
  )

candidate_summary_wide

# Example 14: Time-based pivot (if date columns exist)
if ("date" %in% colnames(events_data) || "event_date" %in% colnames(events_data)) {
  date_col <- ifelse("date" %in% colnames(events_data), "date", "event_date")
  
  # Create month-by-candidate activity matrix
  monthly_activity <- events_data %>%
    filter(cand_name %in% top_candidates) %>%
    mutate(
      month = format(get(date_col), "%Y-%m")
    ) %>%
    group_by(cand_name, month) %>%
    summarise(
      events = n(),
      .groups = "drop"
    ) %>%
    pivot_wider(
      names_from = month,
      values_from = events,
      values_fill = 0
    )
  
  monthly_activity
}

# ============================================================================
# PIVOT_WIDER BEST PRACTICES
# ============================================================================
# 1. Always specify values_fill to handle missing combinations
# 2. Use names_from for the column that becomes new column names
# 3. Use values_from for the column that fills the new columns
# 4. Filter data first to avoid overly wide tables
# 5. Consider using pivot_longer() to reverse the transformation
# 6. Combine with group_by() and summarise() for aggregated pivots

# ============================================================================
# JOINING DATASETS
# ============================================================================

# Real data analysis often requires combining information from multiple sources.
# The tidyverse provides powerful join functions to merge datasets based on
# common columns (keys). Let's create a sample dataset to demonstrate joins.

# Create a sample candidate demographics dataset
candidate_info <- tibble(
  cand_name = c("Biden", "Trump", "Harris", "DeSantis", "Haley", "Ramaswamy"),
  party = c("Democrat", "Republican", "Democrat", "Republican", "Republican", "Republican"),
  age = c(80, 77, 59, 45, 52, 38),
  home_state = c("DE", "FL", "CA", "FL", "SC", "OH")
)

candidate_info

# Example 15: LEFT JOIN - Keep all events, add candidate info where available
# This is the most common type of join
events_with_info <- events_data %>%
  left_join(candidate_info, by = "cand_name")

head(events_with_info)

# Check dimensions - should have same number of rows as events_data
nrow(events_data)  # Original events
nrow(events_with_info)  # After left join

# Example 16: INNER JOIN - Only keep events for candidates we have info about
events_inner <- events_data %>%
  inner_join(candidate_info, by = "cand_name")

head(events_inner)
nrow(events_inner)  # Likely fewer rows than original

# See which candidates we lost
events_data %>%
  anti_join(candidate_info, by = "cand_name") %>%
  distinct(cand_name)

# Example 17: Creating state information dataset for another join example
state_info <- tibble(
  state = c("IA", "NH", "SC", "NV", "CA", "TX", "FL", "NY", "PA", "OH"),
  region = c("Midwest", "Northeast", "South", "West", "West", "South", 
             "South", "Northeast", "Northeast", "Midwest"),
  electoral_votes = c(6, 4, 9, 6, 54, 40, 30, 28, 19, 17),
  population_millions = c(3.2, 1.4, 5.2, 3.1, 39.0, 30.0, 22.6, 19.3, 13.0, 11.8)
)

state_info

# Example 18: Multiple joins - Add both candidate and state information
comprehensive_data <- events_data %>%
  left_join(candidate_info, by = "cand_name") %>%
  left_join(state_info, by = "state")

head(comprehensive_data)

# Example 19: Analysis with joined data
# Now we can analyze by party and region
party_region_analysis <- comprehensive_data %>%
  filter(!is.na(party), !is.na(region)) %>%
  group_by(party, region) %>%
  summarise(
    events = n(),
    candidates = n_distinct(cand_name),
    avg_electoral_votes = round(mean(electoral_votes, na.rm = TRUE), 1),
    .groups = "drop"
  ) %>%
  arrange(desc(events))

party_region_analysis

# Example 20: Join with different column names
# Sometimes the key columns have different names in each dataset
# Create a dataset with different column name
candidate_polling <- tibble(
  candidate = c("Biden", "Trump", "Harris", "DeSantis", "Haley"),
  avg_poll_pct = c(45.2, 42.8, 38.5, 15.3, 8.7),
  poll_trend = c("stable", "rising", "falling", "stable", "falling")
)

# Join using different column names
events_with_polls <- events_data %>%
  left_join(candidate_polling, by = c("cand_name" = "candidate"))

head(events_with_polls)

# Example 21: Analyzing campaign strategy with joined data
campaign_strategy <- events_with_polls %>%
  filter(!is.na(avg_poll_pct)) %>%
  group_by(cand_name) %>%
  summarise(
    total_events = n(),
    states_visited = n_distinct(state),
    avg_poll_pct = first(avg_poll_pct),
    events_per_poll_point = round(total_events / avg_poll_pct, 2),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_poll_pct))

campaign_strategy

# Example 22: FULL JOIN - Keep all rows from both datasets
# Create a small example to show the difference
sample_events <- events_data %>%
  distinct(cand_name) %>%
  head(5)

sample_candidates <- candidate_info %>%
  head(4)

# Inner join - only matching candidates
sample_events %>%
  inner_join(sample_candidates, by = "cand_name")

# Full join - all candidates from both datasets
sample_events %>%
  full_join(sample_candidates, by = "cand_name")

# ============================================================================
# JOIN TYPES SUMMARY
# ============================================================================
# left_join(x, y): Keep all rows from x, add matching info from y
# right_join(x, y): Keep all rows from y, add matching info from x  
# inner_join(x, y): Only keep rows that match in both datasets
# full_join(x, y): Keep all rows from both datasets
# anti_join(x, y): Keep rows from x that DON'T match y
# semi_join(x, y): Keep rows from x that DO match y (but don't add y's columns)

# ============================================================================
# KEY TAKEAWAYS
# ============================================================================
# 1. group_by() creates groups for analysis
# 2. summarise() calculates statistics within groups
# 3. n() counts rows, n_distinct() counts unique values
# 4. Use .groups = "drop" to ungroup after summarizing
# 5. Chain operations with %>% for readable code
# 6. Combine with filter(), arrange(), mutate() for complex analysis
# 7. pivot_wider() transforms long data to wide format for comparisons
# 8. Use values_fill to handle missing data combinations
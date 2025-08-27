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
# SMPA Making Webpages

A collection of R tutorials and examples for creating interactive web content using R, specifically focused on data visualization and web table creation for journalism and data analysis.

## Overview

This repository contains educational materials for learning how to create web-ready data visualizations and interactive components using R. The content is designed for students and professionals in journalism, communications, and data analysis who want to publish their work on the web.

## Contents

### Tutorial Files

- **`01_searchable_web_tables.qmd`** - Complete tutorial for creating searchable, filterable database tables using the DT package
- **`02_plotly_charts.qmd`** - Comprehensive guide to interactive data visualization with Plotly in R

### Generated Outputs

- **`01_searchable_web_tables.html`** - Rendered HTML version of the web tables tutorial
- **`candidatetracker.html`** - Standalone interactive table showing presidential candidate campaign trips
- **`mytable.html`** - Example searchable table export

### Data Files

- **`events_saved.rds`** - Presidential candidate campaign trip data used in tutorials
- **`ga_runoff_ads.rds`** - Additional dataset for examples

## Key Features Covered

### Interactive Web Tables (DT Package)
- Creating sortable, searchable data tables
- Adding filters for better data exploration
- Implementing download/export buttons (CSV, Excel, PDF)
- Custom styling and formatting
- Converting factor columns for proper filtering

### Interactive Data Visualization (Plotly)
- Basic scatter plots and line charts
- Multi-series visualizations
- Bar charts (grouped, stacked, custom colored)
- Pie and donut charts
- Advanced multi-layer plots
- Custom hover information and tooltips
- Color-blind friendly palettes
- Performance optimization for large datasets

## Getting Started

1. **Prerequisites**: Ensure you have R installed with the following packages:
   ```r
   install.packages(c("tidyverse", "DT", "plotly", "lubridate"))
   ```

2. **Run the tutorials**: Open the `.qmd` files in RStudio and render them to HTML to see the interactive elements

3. **Explore the outputs**: Open the generated `.html` files in your web browser to interact with the examples

## Educational Objectives

Students will learn to:
- Create publication-ready interactive data tables for the web
- Build engaging data visualizations that readers can explore
- Export standalone HTML files that can be hosted anywhere
- Apply best practices for web accessibility and user experience
- Understand when to use different chart types for effective communication

## Use Cases

- **Journalism**: Create interactive data stories and searchable databases for news articles
- **Research**: Share findings through interactive visualizations and searchable datasets
- **Education**: Build engaging materials for data literacy and visualization courses
- **Public Affairs**: Present government data and policy analysis in accessible formats

## Technical Notes

- All outputs are self-contained HTML files that work without server requirements
- Compatible with any web hosting platform
- Uses modern web standards for interactivity
- Responsive design works on desktop and mobile devices

## Project Structure

```
├── README.md                           # This file
├── 01_searchable_web_tables.qmd        # Web tables tutorial
├── 02_plotly_charts.qmd               # Plotly visualization tutorial
├── *.html                             # Generated tutorial outputs
├── *.rds                              # Sample datasets
└── smpa_making_webpages.Rproj         # RStudio project file
```
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an R-based educational repository containing tutorials for creating interactive web content. The codebase focuses on two main areas: searchable web tables using the DT package and interactive data visualizations using Plotly. All content is designed as self-contained HTML outputs that can be hosted anywhere without server requirements.

## Development Commands

### Rendering Documents
- **Render Quarto documents**: Open `.qmd` files in RStudio and use the "Render" button, or use `quarto render filename.qmd` in terminal
- **View outputs**: Open generated `.html` files in web browser to interact with examples

### Package Management
Required R packages (install if missing):
```r
install.packages(c("tidyverse", "DT", "plotly", "lubridate"))
```

## Architecture and Structure

### Core Tutorial Files
- `01_searchable_web_tables.qmd` - Complete tutorial covering DT package for interactive tables with filtering, sorting, and export functionality
- `02_plotly_charts.qmd` - Comprehensive guide to Plotly visualizations including scatter plots, bar charts, multi-layer plots, and accessibility practices

### Output Generation
- All `.qmd` files render to self-contained HTML with embedded interactivity
- Generated HTML files work independently without R or server requirements
- Uses Quarto format with `self-contained: true` for portability

### Data Handling
- Uses `.rds` format for R-specific data storage (events_saved.rds, ga_runoff_ads.rds)
- Focuses on real-world datasets like presidential candidate campaign trips
- Emphasizes data preparation for web visualization (factor conversion, date handling)

### Web Output Philosophy
- All outputs designed for journalism and educational contexts
- Emphasizes accessibility and responsive design
- Creates standalone web components that can be embedded in articles or shared independently

## Code Patterns

### DT Table Creation
- Use `DT::datatable()` with `rownames = FALSE` and `filter = "top"` for standard searchable tables
- Include export buttons with `buttons = c('csv', 'excel', 'pdf')` extensions
- Convert factors to character for proper filtering: `mutate_if(is.factor, as.character)`

### Plotly Visualization
- Start with ggplot2 syntax, convert using `ggplotly()`
- Use `plot_ly()` for more complex interactive features
- Implement color-blind friendly palettes and accessibility features
- Add custom hover information and tooltips for better user experience
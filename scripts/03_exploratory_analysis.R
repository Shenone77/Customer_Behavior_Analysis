# E-Commerce Customer Behavior EDA
# Script 4: Visualizations
# Author: G. Sharavan
# Date: 2026-03-11

# Load libraries
library(tidyverse)
library(scales) # Required for fixing the overlapping money scale
library(lubridate)

# Load data (using the tables generated in Script 3)
monthly_revenue <- read_csv("outputs/tables/monthly_revenue.csv")
top_products_revenue <- read_csv("outputs/tables/top_products_by_revenue.csv")
country_summary <- read_csv("outputs/tables/country_summary.csv")
seasonal_summary <- read_csv("outputs/tables/seasonal_summary.csv")
# Load the raw clean data for hourly/daily plots
ecommerce_clean <- readRDS("data/cleaned_data.rds")

# Ensure directories exist
if(!dir.exists("outputs/plots")) dir.create("outputs/plots", recursive = TRUE)

# === 3.1 FIX: MONTHLY REVENUE TREND (Fixing Year Overlap) ===
# We use factor(year_month) and rotate the labels 45 degrees
p1 <- ggplot(monthly_revenue, aes(x = factor(year_month, levels = year_month), y = monthly_revenue, group = 1)) +
  geom_line(color = "steelblue", size = 1) +
  geom_point(color = "steelblue", size = 2) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) + # Fixes the overlap
  labs(title = "Monthly Revenue Trend", 
       x = "Year-Month", 
       y = "Total Revenue ($)")

ggsave("outputs/plots/monthly_revenue_trend.png", p1, width = 15, height = 6)

# === 3.2 FIX: DAILY REVENUE HEATMAP (Fixing Money Overlap) ===
daily_revenue_data <- ecommerce_clean %>%
  mutate(
    date = as.Date(invoice_date),
    day = day(date),
    month_name = month(date, label = TRUE)
  ) %>%
  group_by(day, month_name) %>%
  summarise(revenue = sum(revenue), .groups = "drop")

# Ensure correct month order
daily_revenue_data$month_name <- factor(
  daily_revenue_data$month_name,
  levels = month.abb
)

p2 <- ggplot(daily_revenue_data,
             aes(x = day, y = month_name, fill = revenue)) +
  
  geom_tile(color = "black", size = 0.3) +
  
  scale_fill_gradient(
    low = "white",
    high = "red",
    labels = scales::label_number(scale = 1e-3, suffix = "K")
  ) +
  
  scale_x_continuous(breaks = seq(1,31,2)) +
  
  theme_minimal() +
  
  theme(
    axis.text = element_text(size = 10),
    panel.grid = element_blank()
  ) +
  
  labs(
    title = "Daily Revenue Heatmap",
    x = "Day of Month",
    y = "Month",
    fill = "Revenue (K)"
  )

ggsave("outputs/plots/daily_revenue_heatmap.png", p2, width = 12, height = 6)

# === 5.2 FIX: HOURLY SALES PATTERN (Fixing Straight Line) ===

hourly_patterns <- ecommerce_clean %>%
  mutate(hour = lubridate::hour(invoice_date)) %>%
  group_by(hour) %>%
  summarise(n_transactions = n(), .groups = "drop")

# Ensure all hours 0–23 appear
hourly_patterns$hour <- factor(hourly_patterns$hour, levels = 0:23)

p3 <- ggplot(hourly_patterns,
             aes(x = hour, y = n_transactions, group = 1)) +
  
  geom_line(color = "darkgreen", size = 1) +
  geom_point(color = "darkgreen", size = 2) +
  
  scale_x_discrete(drop = FALSE) +
  
  theme_minimal() +
  
  theme(axis.text.x = element_text(angle = 45)) +
  
  labs(
    title = "Hourly Sales Pattern",
    x = "Hour of Day (0–23)",
    y = "Number of Transactions"
  )

ggsave("outputs/plots/hourly_sales_pattern.png", p3, width = 10, height = 6)

# === ADDITIONAL PLOTS ===

# Top 10 Countries Revenue
p4 <- ggplot(head(country_summary, 10), aes(x = reorder(country, total_revenue), y = total_revenue)) +
  geom_col(fill = "orange") +
  coord_flip() +
  scale_y_continuous(labels = label_number(suffix = "M", scale = 1e-6)) +
  theme_minimal() +
  labs(title = "Top 10 Countries by Revenue", x = "Country", y = "Revenue ($ Millions)")

ggsave("outputs/plots/top_countries_revenue.png", p4, width = 10, height = 6)

# Seasonal Revenue
p5 <- ggplot(seasonal_summary, aes(x = season, y = total_revenue, fill = season)) +
  geom_col() +
  theme_minimal() +
  labs(title = "Total Revenue by Season", x = "Season", y = "Revenue ($)")

ggsave("outputs/plots/seasonal_revenue.png", p5, width = 10, height = 6)

cat("\nDone! All corrected plots have been saved to 'outputs/plots/'.\n")


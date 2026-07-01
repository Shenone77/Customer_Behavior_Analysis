# E-Commerce Customer Behavior EDA
# Script 4: Visualizations
# Author: Senior Data Analyst
# Date: 2024

# Load libraries
library(tidyverse)
library(ggplot2)
library(viridis)
library(scales)
library(corrplot)
library(GGally)

# Set theme
theme_set(theme_minimal() + 
            theme(plot.title = element_text(size = 14, face = "bold"),
                  axis.text = element_text(size = 10),
                  legend.position = "bottom"))

# Load data
ecommerce_clean <- readRDS("data/cleaned_data.rds")

# Load analysis results
monthly_revenue <- read_csv("outputs/tables/monthly_revenue.csv")
top_products_revenue <- read_csv("outputs/tables/top_products_by_revenue.csv")
country_summary <- read_csv("outputs/tables/country_summary.csv")
seasonal_summary <- read_csv("outputs/tables/seasonal_summary.csv")

# === 1. REVENUE TREND VISUALIZATIONS ===

# Monthly revenue trend
p1 <- monthly_revenue %>%
  ggplot(aes(x = factor(paste(year, month, sep = "-")), y = monthly_revenue)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  geom_smooth(aes(group = 1), method = "loess", se = FALSE, color = "red", size = 1) +
  scale_y_continuous(labels = scales::dollar) +
  labs(title = "Monthly Revenue Trend",
       subtitle = "E-commerce sales performance over time",
       x = "Month",
       y = "Revenue") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("outputs/plots/monthly_revenue_trend.png", p1, width = 12, height = 6, dpi = 300)

# Daily revenue heatmap
daily_data <- ecommerce_clean %>%
  mutate(date = as.Date(invoice_date),
         month = month(date),
         day = day(date)) %>%
  group_by(month, day) %>%
  summarise(daily_revenue = sum(revenue), .groups = "drop")

p2 <- ggplot(daily_data, aes(x = day, y = factor(month), fill = daily_revenue)) +
  geom_tile() +
  scale_fill_viridis(labels = scales::dollar) +
  labs(title = "Daily Revenue Heatmap",
       subtitle = "Revenue intensity by day of month",
       x = "Day of Month",
       y = "Month",
       fill = "Revenue") +
  scale_y_discrete(labels = month.abb)

ggsave("outputs/plots/daily_revenue_heatmap.png", p2, width = 10, height = 6, dpi = 300)

# === 2. TOP PRODUCTS VISUALIZATION ===

# Top 15 products by revenue
p3 <- top_products_revenue %>%
  head(15) %>%
  ggplot(aes(x = reorder(description, total_revenue), y = total_revenue)) +
  geom_bar(stat = "identity", fill = "darkgreen") +
  coord_flip() +
  scale_y_continuous(labels = scales::dollar) +
  labs(title = "Top 15 Products by Revenue",
       subtitle = "Best-selling products in the e-commerce store",
       x = "Product",
       y = "Total Revenue")

ggsave("outputs/plots/top_products_revenue.png", p3, width = 10, height = 8, dpi = 300)

# === 3. CUSTOMER BEHAVIOR VISUALIZATIONS ===

# Customer purchase frequency
customer_data <- ecommerce_clean %>%
  group_by(customer_id) %>%
  summarise(n_purchases = n_distinct(invoice_no),
            total_spent = sum(revenue)) %>%
  filter(customer_id != "Unknown")

p4 <- ggplot(customer_data, aes(x = n_purchases)) +
  geom_histogram(bins = 50, fill = "coral", color = "black", alpha = 0.7) +
  scale_x_continuous(limits = c(0, 50)) +
  labs(title = "Customer Purchase Frequency Distribution",
       subtitle = "How many times do customers make purchases?",
       x = "Number of Purchases",
       y = "Number of Customers")

ggsave("outputs/plots/customer_purchase_frequency.png", p4, width = 10, height = 6, dpi = 300)

# Customer value distribution
p5 <- customer_data %>%
  filter(total_spent < quantile(total_spent, 0.95)) %>%
  ggplot(aes(x = total_spent)) +
  geom_histogram(bins = 50, fill = "purple", alpha = 0.7) +
  scale_x_continuous(labels = scales::dollar) +
  labs(title = "Customer Lifetime Value Distribution",
       subtitle = "Distribution of total spending per customer (95th percentile)",
       x = "Total Spent",
       y = "Number of Customers")

ggsave("outputs/plots/customer_value_distribution.png", p5, width = 10, height = 6, dpi = 300)

# === 4. SEASONAL TRENDS ===

# Seasonal revenue
p6 <- seasonal_summary %>%
  ggplot(aes(x = season, y = total_revenue, fill = season)) +
  geom_bar(stat = "identity") +
  scale_fill_viridis_d() +
  scale_y_continuous(labels = scales::dollar) +
  labs(title = "Revenue by Season",
       subtitle = "Seasonal patterns in e-commerce sales",
       x = "Season",
       y = "Total Revenue") +
  theme(legend.position = "none")

ggsave("outputs/plots/seasonal_revenue.png", p6, width = 8, height = 6, dpi = 300)

# Hourly sales pattern
hourly_data <- ecommerce_clean %>%
  group_by(hour) %>%
  summarise(avg_transactions = n() / n_distinct(as.Date(invoice_date)))

p7 <- ggplot(hourly_data, aes(x = hour, y = avg_transactions)) +
  geom_line(color = "blue", size = 1.5) +
  geom_point(color = "blue", size = 3) +
  scale_x_continuous(breaks = seq(0, 23, 2)) +
  labs(title = "Average Transactions by Hour of Day",
       subtitle = "When are customers most active?",
       x = "Hour of Day",
       y = "Average Transactions")

ggsave("outputs/plots/hourly_sales_pattern.png", p7, width = 10, height = 6, dpi = 300)

# === 5. GEOGRAPHIC ANALYSIS ===

# Top 10 countries by revenue
p8 <- country_summary %>%
  head(10) %>%
  ggplot(aes(x = reorder(country, total_revenue), y = total_revenue)) +
  geom_bar(stat = "identity", fill = "navy") +
  coord_flip() +
  scale_y_continuous(labels = scales::dollar) +
  labs(title = "Top 10 Countries by Revenue",
       subtitle = "Geographic distribution of sales",
       x = "Country",
       y = "Total Revenue")

ggsave("outputs/plots/top_countries_revenue.png", p8, width = 10, height = 6, dpi = 300)

# === 6. CORRELATION ANALYSIS ===

# Prepare correlation data
cor_data <- ecommerce_clean %>%
  select(quantity, unit_price, revenue, hour, day, month) %>%
  cor(use = "complete.obs")

# Correlation heatmap
png("outputs/plots/correlation_heatmap.png", width = 800, height = 600)
corrplot(cor_data, 
         method = "color",
         type = "upper",
         order = "hclust",
         addCoef.col = "black",
         tl.col = "black",
         tl.srt = 45,
         diag = FALSE,
         title = "Correlation Matrix of Key Variables")
dev.off()

# === 7. PRODUCT MIX ANALYSIS ===

# Weekly pattern
weekly_data <- ecommerce_clean %>%
  group_by(weekday) %>%
  summarise(total_revenue = sum(revenue)) %>%
  mutate(weekday = factor(weekday, levels = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")))

p9 <- ggplot(weekly_data, aes(x = weekday, y = total_revenue, fill = weekday)) +
  geom_bar(stat = "identity") +
  scale_fill_brewer(palette = "Set3") +
  scale_y_continuous(labels = scales::dollar) +
  labs(title = "Revenue by Day of Week",
       subtitle = "Weekly sales patterns",
       x = "Day of Week",
       y = "Total Revenue") +
  theme(legend.position = "none")

ggsave("outputs/plots/weekly_revenue_pattern.png", p9, width = 8, height = 6, dpi = 300)

# === 8. ADVANCED VISUALIZATIONS ===

# Box plot of transaction values by month
p10 <- ecommerce_clean %>%
  filter(revenue < quantile(revenue, 0.95)) %>%
  ggplot(aes(x = factor(month), y = revenue, fill = factor(month))) +
  geom_boxplot(alpha = 0.7) +
  scale_fill_viridis_d() +
  scale_y_continuous(labels = scales::dollar) +
  labs(title = "Transaction Value Distribution by Month",
       subtitle = "Box plot showing revenue distribution (95th percentile)",
       x = "Month",
       y = "Transaction Value") +
  theme(legend.position = "none")

ggsave("outputs/plots/transaction_value_by_month.png", p10, width = 10, height = 6, dpi = 300)

cat("\n=== ALL VISUALIZATIONS SAVED ===\n")
cat("Location: outputs/plots/\n")
cat("Total plots generated: 10\n")

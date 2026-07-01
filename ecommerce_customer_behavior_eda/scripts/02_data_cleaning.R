# E-Commerce Customer Behavior EDA
# Script 2: Data Cleaning and Preprocessing
# Author: Senior Data Analyst
# Date: 2024

# Load libraries
library(tidyverse)
library(janitor)
library(lubridate)

# Load raw data
ecommerce_data <- readRDS("data/raw_data.rds")

# Clean column names (make them consistent)
ecommerce_clean <- ecommerce_data %>%
  clean_names()

# Assuming typical e-commerce dataset columns:
# InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, CustomerID, Country

# Convert data types
ecommerce_clean <- ecommerce_clean %>%
  mutate(
    invoice_date = parse_date_time(invoice_date, orders = c("ymd HMS", "dmy HMS", "mdy HMS")),
    customer_id = as.character(customer_id),
    quantity = as.numeric(quantity),
    unit_price = as.numeric(unit_price)
  )

# Create additional features
ecommerce_clean <- ecommerce_clean %>%
  mutate(
    # Revenue calculation
    revenue = quantity * unit_price,
    
    # Date features
    year = year(invoice_date),
    month = month(invoice_date),
    month_name = month(invoice_date, label = TRUE),
    day = day(invoice_date),
    weekday = wday(invoice_date, label = TRUE),
    hour = hour(invoice_date),
    
    # Quarter
    quarter = quarter(invoice_date),
    
    # Season (Northern Hemisphere)
    season = case_when(
      month %in% c(12, 1, 2) ~ "Winter",
      month %in% c(3, 4, 5) ~ "Spring",
      month %in% c(6, 7, 8) ~ "Summer",
      month %in% c(9, 10, 11) ~ "Fall"
    )
  )

# Handle missing values
cat("\n=== MISSING VALUES ANALYSIS ===\n")
missing_summary <- ecommerce_clean %>%
  summarise_all(~sum(is.na(.))) %>%
  pivot_longer(everything(), names_to = "column", values_to = "missing_count") %>%
  mutate(missing_pct = round(missing_count / nrow(ecommerce_clean) * 100, 2))

print(missing_summary)

# Remove rows with negative quantities (returns)
returns_data <- ecommerce_clean %>%
  filter(quantity < 0)

cat("\nNumber of return transactions:", nrow(returns_data), "\n")

# Keep only positive transactions for main analysis
ecommerce_clean <- ecommerce_clean %>%
  filter(quantity > 0, unit_price > 0)

# Remove outliers using IQR method for revenue
Q1 <- quantile(ecommerce_clean$revenue, 0.25, na.rm = TRUE)
Q3 <- quantile(ecommerce_clean$revenue, 0.75, na.rm = TRUE)
IQR <- Q3 - Q1

# Define outlier bounds
lower_bound <- Q1 - 1.5 * IQR
upper_bound <- Q3 + 1.5 * IQR

# Flag outliers but don't remove them yet
ecommerce_clean <- ecommerce_clean %>%
  mutate(is_outlier = revenue < lower_bound | revenue > upper_bound)

cat("\nOutliers detected:", sum(ecommerce_clean$is_outlier), "\n")

# Handle missing customer IDs
ecommerce_clean <- ecommerce_clean %>%
  mutate(customer_id = ifelse(is.na(customer_id), "Unknown", customer_id))

# Remove duplicates
ecommerce_clean <- ecommerce_clean %>%
  distinct()

# Data quality checks
cat("\n=== DATA QUALITY SUMMARY ===\n")
cat("Original rows:", nrow(ecommerce_data), "\n")
cat("Cleaned rows:", nrow(ecommerce_clean), "\n")
cat("Rows removed:", nrow(ecommerce_data) - nrow(ecommerce_clean), "\n")
cat("Unique customers:", n_distinct(ecommerce_clean$customer_id), "\n")
cat("Unique products:", n_distinct(ecommerce_clean$stock_code), "\n")
cat("Date range:", min(ecommerce_clean$invoice_date), "-", max(ecommerce_clean$invoice_date), "\n")

# Save cleaned data
write_csv(ecommerce_clean, "data/cleaned_data.csv")
saveRDS(ecommerce_clean, "data/cleaned_data.rds")

# Save cleaning summary
sink("outputs/summary_reports/data_cleaning_summary.txt")
cat("=== DATA CLEANING SUMMARY ===\n")
cat("Date:", Sys.Date(), "\n\n")
cat("Original dataset rows:", nrow(ecommerce_data), "\n")
cat("Cleaned dataset rows:", nrow(ecommerce_clean), "\n")
cat("Return transactions removed:", nrow(returns_data), "\n")
cat("Missing CustomerID replaced:", sum(ecommerce_clean$customer_id == "Unknown"), "\n")
print(missing_summary)
sink()
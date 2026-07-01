# E-Commerce Customer Behavior EDA
# Script 1: Data Loading and Initial Exploration
# Author: Senior Data Analyst
# Date: 2024

# Load libraries
library(tidyverse)
library(skimr)
library(janitor)
library(lubridate)

# Set working directory


# Create directory structure if not exists
dir.create("data", showWarnings = FALSE)
dir.create("scripts", showWarnings = FALSE)
dir.create("outputs", showWarnings = FALSE)
dir.create("outputs/plots", showWarnings = FALSE)
dir.create("outputs/tables", showWarnings = FALSE)
dir.create("outputs/summary_reports", showWarnings = FALSE)
dir.create("report", showWarnings = FALSE)

# Load the dataset
# Note: Replace with your actual file path after downloading from Kaggle
ecommerce_data <- read_csv("data/raw_data.csv")

# Initial data exploration
cat("=== DATASET OVERVIEW ===\n")
cat("Dimensions:", dim(ecommerce_data), "\n")
cat("Columns:", names(ecommerce_data), "\n\n")

# View first few rows
print(head(ecommerce_data))

# Data structure
str(ecommerce_data)

# Summary statistics
summary(ecommerce_data)

# Detailed data summary using skimr
skim_output <- skim(ecommerce_data)
print(skim_output)

# Save initial exploration results
sink("outputs/summary_reports/initial_exploration.txt")
cat("=== E-COMMERCE DATA INITIAL EXPLORATION ===\n")
cat("Date:", Sys.Date(), "\n\n")
cat("Dataset Dimensions:\n")
cat("Rows:", nrow(ecommerce_data), "\n")
cat("Columns:", ncol(ecommerce_data), "\n\n")
cat("Column Names:\n")
print(names(ecommerce_data))
cat("\n\nData Types:\n")
print(sapply(ecommerce_data, class))
cat("\n\nMissing Values:\n")
print(colSums(is.na(ecommerce_data)))
sink()

# Check for duplicates
duplicates <- sum(duplicated(ecommerce_data))
cat("\nDuplicate rows:", duplicates, "\n")

# Save raw data info
saveRDS(ecommerce_data, "data/raw_data.rds")